import UIKit
import SDWebImage
import ObjectiveC


private var deepLinkKey: UInt8 = 0

// MARK: - CTFiveIconsViewController

@objc public class CTFiveIconsViewController: BaseCTNotificationContentViewController {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""

    private var model: CTFiveIconsModel?
    private var stackView: UIStackView = UIStackView()

    // Payload-driven colours
    private var bgColor: String = ConstantKeys.kDefaultColor
    private var bgColorDark: String = ConstantKeys.kDefaultColorDark

    private var cachedBgColor: UIColor?

    private var titleColor: String     = "#000000"
    private var titleColorDark: String = "#FFFFFF"
    private var msgColor: String       = "#000000"
    private var msgColorDark: String   = "#FFFFFF"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Layout constants
    private let kHorizontalPadding: CGFloat = 16.0
    private let kVerticalPadding: CGFloat   = 10.0
    private let kLabelSpacing: CGFloat      = 4.0
    private let kIconSpacing: CGFloat       = 10.0

    // MARK: - Lifecycle

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        model = CTUtiltiy.loadContentData(data: data)

        if let bg     = model?.pt_bg,                  !bg.isEmpty     { bgColor          = bg }
        if let bgDark = model?.pt_bg_dark,             !bgDark.isEmpty { bgColorDark      = bgDark }
        if let tc  = model?.pt_title_clr,      !tc.isEmpty  { titleColor     = tc }
        if let tcd = model?.pt_title_clr_dark, !tcd.isEmpty { titleColorDark = tcd }
        if let mc  = model?.pt_msg_clr,        !mc.isEmpty  { msgColor       = mc }
        if let mcd = model?.pt_msg_clr_dark,   !mcd.isEmpty { msgColorDark   = mcd }

        rebuildColorCache()
        applyTheme()
        prepareAndRenderRow()

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
                self.rebuildColorCache()
                self.applyTheme()
            }
        }
    }

    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 17.0, *) { return }
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                rebuildColorCache()
                applyTheme()
            }
        }
    }

    // MARK: - Row Setup

    private typealias IconItem = (imageURL: String, deepLink: String?)
    private typealias ValidatedIcon = (item: IconItem, image: UIImage)

    private let kPrefetchTimeout: TimeInterval = 3.5
    private let kMinIcons = 3
    private let kMaxIcons = 5

    private func prepareAndRenderRow() {
        let icons = Array((model?.iconItems ?? []).prefix(kMaxIcons))
        guard icons.count >= kMinIcons else {
            renderTextOnly()
            return
        }
        prefetchIcons(icons, timeout: kPrefetchTimeout) { [weak self] validated in
            guard let self = self else { return }
            if validated.count >= self.kMinIcons {
                self.setupIconRow(validated: validated)
            } else {
                self.renderTextOnly()
            }
        }
    }

    private func prefetchIcons(
        _ items: [IconItem],
        timeout: TimeInterval,
        completion: @escaping ([ValidatedIcon]) -> Void
    ) {
        var slots = [UIImage?](repeating: nil, count: items.count)
        var settled = 0
        var didFinish = false
        let lock = NSLock()

        func finish() {
            lock.lock()
            if didFinish { lock.unlock(); return }
            didFinish = true
            let snapshot = slots
            lock.unlock()
            let validated: [ValidatedIcon] = zip(items, snapshot).compactMap { pair in
                guard let img = pair.1 else { return nil }
                return (pair.0, img)
            }
            DispatchQueue.main.async { completion(validated) }
        }

        for (idx, it) in items.enumerated() {
            guard let url = URL(string: it.imageURL) else {
                lock.lock(); settled += 1; let done = settled == items.count; lock.unlock()
                if done { finish() }
                continue
            }
            SDWebImageManager.shared.loadImage(with: url, options: [.retryFailed], progress: nil) { image, _, _, _, finished, _ in
                guard finished else { return }
                lock.lock()
                slots[idx] = image
                settled += 1
                let done = settled == items.count
                lock.unlock()
                if done { finish() }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { finish() }
    }

    private func resolvedTitle() -> String? {
        if let t = model?.pt_title, !t.isEmpty { return t }
        return templateCaption.isEmpty ? nil : templateCaption
    }

    private func resolvedMessage() -> String? {
        if let m = model?.pt_msg, !m.isEmpty { return m }
        return templateSubcaption.isEmpty ? nil : templateSubcaption
    }

    private func renderTextOnly() {
        let titleText = resolvedTitle()
        let msgText   = resolvedMessage()

        let availableTextWidth = max(view.bounds.width - 2 * kHorizontalPadding, 1)
        let labelFittingSize = CGSize(width: availableTextWidth, height: .greatestFiniteMagnitude)

        var topAnchor: NSLayoutYAxisAnchor = view.topAnchor
        var totalHeight: CGFloat = 0

        if let title = titleText {
            titleLabel.text = title
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: kVerticalPadding),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            ])
            topAnchor = titleLabel.bottomAnchor
            totalHeight += kVerticalPadding + ceil(titleLabel.sizeThatFits(labelFittingSize).height)
        }

        if let msg = msgText {
            messageLabel.text = msg
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleText != nil ? kLabelSpacing : kVerticalPadding),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            ])
            topAnchor = messageLabel.bottomAnchor
            totalHeight += (titleText != nil ? kLabelSpacing : kVerticalPadding) + ceil(messageLabel.sizeThatFits(labelFittingSize).height)
        }

        if let lastLabel = msgText != nil ? messageLabel : (titleText != nil ? titleLabel : nil) {
            lastLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -kVerticalPadding).isActive = true
            totalHeight += kVerticalPadding
        } else {
            totalHeight = kVerticalPadding * 2
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    private func setupIconRow(validated: [ValidatedIcon]) {
        let titleText = resolvedTitle()
        let msgText   = resolvedMessage()

        let availableTextWidth = max(view.bounds.width - 2 * kHorizontalPadding, 1)

        let n = CGFloat(validated.count)
        let cellWidth: CGFloat = max((availableTextWidth - (n - 1) * kIconSpacing) / n, 0)

        let cellHeights: [CGFloat] = validated.map { entry in
            let img = entry.image
            guard img.size.width > 0 else { return 0 }
            return cellWidth * (img.size.height / img.size.width)
        }
        let rowHeight = cellHeights.max() ?? 0

        let kIconRowTopSpacing: CGFloat    = 8.0
        let kIconRowBottomPadding: CGFloat = 4.0

        var topAnchor: NSLayoutYAxisAnchor = view.topAnchor
        var totalHeight: CGFloat = rowHeight + kIconRowBottomPadding

        if let title = titleText {
            titleLabel.text = title
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: kVerticalPadding),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            ])
            topAnchor = titleLabel.bottomAnchor
            totalHeight += kVerticalPadding + 20
        }

        if let msg = msgText {
            messageLabel.text = msg
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleText != nil ? kLabelSpacing : kVerticalPadding),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            ])
            topAnchor = messageLabel.bottomAnchor
            totalHeight += (titleText != nil ? kLabelSpacing : kVerticalPadding) + 34
        }

        stackView.axis         = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment    = .center
        stackView.spacing      = kIconSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let stackTopInset: CGFloat = (titleText != nil || msgText != nil) ? kIconRowTopSpacing : kVerticalPadding
        totalHeight += stackTopInset
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: stackTopInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            stackView.heightAnchor.constraint(equalToConstant: rowHeight),
        ])

        for (idx, entry) in validated.enumerated() {
            let imageView = makeIconView(
                image: entry.image,
                deepLink: entry.item.deepLink,
                cellWidth: cellWidth,
                cellHeight: cellHeights[idx]
            )
            stackView.addArrangedSubview(imageView)
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    // MARK: - Icon View Factory

    private func makeIconView(image: UIImage, deepLink: String?, cellWidth: CGFloat, cellHeight: CGFloat) -> UIImageView {

        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: cellWidth),
            imageView.heightAnchor.constraint(equalToConstant: cellHeight),
        ])

        if let dl = deepLink, !dl.isEmpty {
            objc_setAssociatedObject(imageView, &deepLinkKey, dl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
            )
        }

        return imageView
    }

    // MARK: - Actions

    @objc private func handleIconTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view,
              let urlString = objc_getAssociatedObject(tappedView, &deepLinkKey) as? String,
              let url = URL(string: urlString) else { return }
        extensionContext?.open(url, completionHandler: nil)
    }

    private var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        return false
    }

    private func rebuildColorCache() {
        cachedBgColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
    }

    func applyTheme() {
        view.backgroundColor = cachedBgColor

        titleLabel.textColor   = UIColor(hex: isDarkMode ? titleColorDark : titleColor)
        messageLabel.textColor = UIColor(hex: isDarkMode ? msgColorDark   : msgColor)
    }

    // MARK: - BaseCTNotificationContentViewController

    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        return .doNotDismiss
    }

    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
