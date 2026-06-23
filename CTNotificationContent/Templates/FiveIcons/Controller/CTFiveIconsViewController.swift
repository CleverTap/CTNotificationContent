import UIKit

// MARK: - CTFiveIconsViewController

@objc public class CTFiveIconsViewController: BaseCTNotificationContentViewController {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""

    private var model: CTFiveIconsModel?
    private var stackView: UIStackView = UIStackView()
    private var iconDeepLinks: [String?] = []

    // Payload-driven colours
    private var bgColor: String = ConstantKeys.kDefaultColor
    private var bgColorDark: String = ConstantKeys.kDefaultColorDark

    private var cachedBgColor: UIColor?

    private var titleColor: String     = ConstantKeys.kHexBlackColor
    private var titleColorDark: String = ConstantKeys.kHexWhiteColor
    private var msgColor: String       = ConstantKeys.kHexBlackColor
    private var msgColorDark: String   = ConstantKeys.kHexWhiteColor

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

    // MARK: - Lifecycle

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        model = CTUtiltiy.loadContentData(data: data)

        if let bg     = model?.pt_bg,                  !bg.isEmpty     { bgColor          = bg }
        if let bgDark = model?.pt_bg_dark,             !bgDark.isEmpty { bgColorDark      = bgDark }
        if let titleClrValue     = model?.pt_title_clr,      !titleClrValue.isEmpty     { titleColor     = titleClrValue }
        if let titleClrDarkValue = model?.pt_title_clr_dark, !titleClrDarkValue.isEmpty { titleColorDark = titleClrDarkValue }
        if let msgClrValue       = model?.pt_msg_clr,        !msgClrValue.isEmpty       { msgColor       = msgClrValue }
        if let msgClrDarkValue   = model?.pt_msg_clr_dark,   !msgClrDarkValue.isEmpty   { msgColorDark   = msgClrDarkValue }

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

    @objc public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pendingTextOnlyRender {
            pendingTextOnlyRender = false
            renderTextOnly()
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

    private let kMinIcons = 3
    private let kMaxIcons = 5
    private var pendingTextOnlyRender = false

    private func prepareAndRenderRow() {
        let icons = Array((model?.iconItems ?? []).prefix(kMaxIcons))
        guard icons.count >= kMinIcons else {
            pendingTextOnlyRender = true
            return
        }
        prefetchIcons(icons) { [weak self] validated in
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
        completion: @escaping ([ValidatedIcon]) -> Void
    ) {
        var slots = [UIImage?](repeating: nil, count: items.count)
        let group = DispatchGroup()

        for (index, item) in items.enumerated() {
            group.enter()
            CTUtiltiy.checkImageUrlValid(imageUrl: item.imageURL) { image in
                slots[index] = image
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let validated: [ValidatedIcon] = zip(items, slots).compactMap { item, image in
                image.map { (item, $0) }
            }
            completion(validated)
        }
    }

    // Used only in the images-loaded path. APS title/body must not bleed in here;
    // that fallback belongs exclusively to renderTextOnly() (images-failed path).
    private func resolvedTitle() -> String? {
        if let title = model?.pt_title, !title.isEmpty { return title }
        return nil
    }

    private func resolvedMessage() -> String? {
        if let msg = model?.pt_msg, !msg.isEmpty { return msg }
        return nil
    }
    
    private func renderTextOnly() {
        let titleText: String? = {
            if let title = model?.pt_title, !title.isEmpty { return title }
            return templateCaption.isEmpty ? nil : templateCaption
        }()
        let msgText: String? = {
            if let message = model?.pt_msg, !message.isEmpty { return message }
            return templateSubcaption.isEmpty ? nil : templateSubcaption
        }()

        let availableTextWidth = max(view.bounds.width - 2 * Constraints.kFiveIconsHorizontalPadding, 1)
        let labelFittingSize = CGSize(width: availableTextWidth, height: .greatestFiniteMagnitude)

        var topAnchor: NSLayoutYAxisAnchor = view.topAnchor
        var totalHeight: CGFloat = 0

        if let title = titleText {
            titleLabel.text = title
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constraints.kFiveIconsVerticalPadding),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  Constraints.kFiveIconsHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constraints.kFiveIconsHorizontalPadding),
            ])
            topAnchor = titleLabel.bottomAnchor
            totalHeight += Constraints.kFiveIconsVerticalPadding + ceil(titleLabel.sizeThatFits(labelFittingSize).height)
        }

        if let msg = msgText {
            messageLabel.text = msg
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleText != nil ? Constraints.kFiveIconsLabelSpacing : Constraints.kFiveIconsVerticalPadding),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  Constraints.kFiveIconsHorizontalPadding),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constraints.kFiveIconsHorizontalPadding),
            ])
            topAnchor = messageLabel.bottomAnchor
            totalHeight += (titleText != nil ? Constraints.kFiveIconsLabelSpacing : Constraints.kFiveIconsVerticalPadding) + ceil(messageLabel.sizeThatFits(labelFittingSize).height)
        }

        if let lastLabel = msgText != nil ? messageLabel : (titleText != nil ? titleLabel : nil) {
            lastLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Constraints.kFiveIconsVerticalPadding).isActive = true
            totalHeight += Constraints.kFiveIconsVerticalPadding
        } else {
            totalHeight = Constraints.kFiveIconsVerticalPadding * 2
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    private func setupIconRow(validated: [ValidatedIcon]) {
        let titleText = resolvedTitle()
        let msgText   = resolvedMessage()

        let availableTextWidth = max(view.bounds.width - 2 * Constraints.kFiveIconsHorizontalPadding, 1)
        let labelFittingSize = CGSize(width: availableTextWidth, height: .greatestFiniteMagnitude)

        let maxIconCount: CGFloat = 5
        let cellWidth: CGFloat = max((availableTextWidth - (maxIconCount - 1) * Constraints.kFiveIconsIconSpacing) / maxIconCount, 0)

        let cellHeights: [CGFloat] = validated.map { entry in
            let img = entry.image
            guard img.size.width > 0 else { return 0 }
            return cellWidth * (img.size.height / img.size.width)
        }
        let rowHeight = cellHeights.max() ?? 0

        let hasText = (titleText != nil) || (msgText != nil)
        let bottomPad: CGFloat = hasText ? Constraints.kFiveIconsRowBottomPadding : Constraints.kFiveIconsNoTextVerticalPad

        var topAnchor: NSLayoutYAxisAnchor = view.topAnchor
        var totalHeight: CGFloat = rowHeight + bottomPad

        if let title = titleText {
            titleLabel.text = title
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constraints.kFiveIconsVerticalPadding),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  Constraints.kFiveIconsHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constraints.kFiveIconsHorizontalPadding),
            ])
            topAnchor = titleLabel.bottomAnchor
            totalHeight += Constraints.kFiveIconsVerticalPadding + ceil(titleLabel.sizeThatFits(labelFittingSize).height)
        }

        if let msg = msgText {
            messageLabel.text = msg
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleText != nil ? Constraints.kFiveIconsLabelSpacing : Constraints.kFiveIconsVerticalPadding),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  Constraints.kFiveIconsHorizontalPadding),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constraints.kFiveIconsHorizontalPadding),
            ])
            topAnchor = messageLabel.bottomAnchor
            totalHeight += (titleText != nil ? Constraints.kFiveIconsLabelSpacing : Constraints.kFiveIconsVerticalPadding) + ceil(messageLabel.sizeThatFits(labelFittingSize).height)
        }

        stackView.axis         = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment    = .center
        stackView.spacing      = Constraints.kFiveIconsIconSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let stackTopInset: CGFloat = hasText ? Constraints.kFiveIconsRowTopSpacing : Constraints.kFiveIconsNoTextVerticalPad
        totalHeight += stackTopInset
        let extraHorizontalInset: CGFloat = (validated.count == 3) ? Constraints.kFiveIconsThreeIconHInset : 0
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: stackTopInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  Constraints.kFiveIconsHorizontalPadding + extraHorizontalInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(Constraints.kFiveIconsHorizontalPadding + extraHorizontalInset)),
            stackView.heightAnchor.constraint(equalToConstant: rowHeight),
        ])

        iconDeepLinks = validated.map { $0.item.deepLink }

        for (idx, entry) in validated.enumerated() {
            let imageView = makeIconView(
                image: entry.image,
                index: idx,
                deepLink: entry.item.deepLink,
                cellWidth: cellWidth,
                cellHeight: cellHeights[idx]
            )
            stackView.addArrangedSubview(imageView)
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    // MARK: - Icon View Factory

    private func makeIconView(image: UIImage, index: Int, deepLink: String?, cellWidth: CGFloat, cellHeight: CGFloat) -> UIImageView {

        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.tag = index

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: cellWidth),
            imageView.heightAnchor.constraint(equalToConstant: cellHeight),
        ])

        if let dl = deepLink, !dl.isEmpty {
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
            )
        }

        return imageView
    }

    // MARK: - Actions

    @objc private func handleIconTap(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag,
              tag < iconDeepLinks.count,
              let urlString = iconDeepLinks[tag],
              let url = URL(string: urlString) else { return }
        getParentViewController().open(url)
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
        if action == ConstantKeys.kAction3 {
            if !deeplinkURL.isEmpty, let url = URL(string: deeplinkURL) {
                getParentViewController().open(url)
            }
            return .dismiss
        }
        return .doNotDismiss
    }

    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
