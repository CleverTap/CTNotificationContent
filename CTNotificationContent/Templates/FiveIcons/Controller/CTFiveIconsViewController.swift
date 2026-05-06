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
        setupIconRow()
        applyTheme()

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

    private func setupIconRow() {
        let titleText = model?.pt_title.flatMap { $0.isEmpty ? nil : $0 }
        let msgText   = model?.pt_msg.flatMap   { $0.isEmpty ? nil : $0 }
        let icons     = Array((model?.iconItems ?? []).prefix(5))
        let hasIcons  = !icons.isEmpty

        let availableTextWidth = max(view.bounds.width - 2 * kHorizontalPadding, 1)
        let labelFittingSize = CGSize(width: availableTextWidth, height: .greatestFiniteMagnitude)

        let iconSize: CGFloat = {
            guard hasIcons else { return 0 }
            let n = CGFloat(icons.count)
            let computed = (availableTextWidth - (n - 1) * kIconSpacing) / n
            let cap = (availableTextWidth - 4 * kIconSpacing) / 4
            return max(min(computed, cap), 0)
        }()

        let kIconRowTopSpacing: CGFloat    = 8.0
        let kIconRowBottomPadding: CGFloat = 4.0

        var topAnchor: NSLayoutYAxisAnchor = view.topAnchor
        var totalHeight: CGFloat = hasIcons ? (iconSize + kIconRowBottomPadding) : 0

        if let title = titleText {
            titleLabel.text = title
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: kVerticalPadding),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant:  kHorizontalPadding),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            ])
            topAnchor = titleLabel.bottomAnchor
            let titleHeight = hasIcons ? 20 : ceil(titleLabel.sizeThatFits(labelFittingSize).height)
            totalHeight += kVerticalPadding + titleHeight
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
            let msgHeight = hasIcons ? 34 : ceil(messageLabel.sizeThatFits(labelFittingSize).height)
            totalHeight += (titleText != nil ? kLabelSpacing : kVerticalPadding) + msgHeight
        }

        if hasIcons {
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
                stackView.heightAnchor.constraint(equalToConstant: iconSize),
            ])

            for item in icons {
                let imageView = makeIconView(imageURL: item.imageURL, deepLink: item.deepLink, size: iconSize)
                stackView.addArrangedSubview(imageView)
                imageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
            }
        } else if let lastLabel = msgText != nil ? messageLabel : (titleText != nil ? titleLabel : nil) {
            lastLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -kVerticalPadding).isActive = true
            totalHeight += kVerticalPadding
        } else {
            totalHeight = kVerticalPadding * 2
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    // MARK: - Icon View Factory

    private func makeIconView(imageURL: String, deepLink: String?, size: CGFloat) -> UIImageView {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let maxWidth = size * 2
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: size)
        widthConstraint.isActive = true

        imageView.sd_setImage(
            with: URL(string: imageURL),
            placeholderImage: nil,
            options: [.retryFailed, .progressiveLoad]
        ) { image, _, _, _ in
            guard let image = image, image.size.height > 0 else { return }
            let aspect = image.size.width / image.size.height
            let nativeWidth = size * aspect
            widthConstraint.constant = min(nativeWidth, maxWidth)
        }

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
