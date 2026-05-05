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
    private var borderColor: String = "#FFFFFF"
    private var borderColorDark: String = "#FFFFFF"

    private var cachedBorderColor: UIColor = .white
    private var cachedBgColor: UIColor?

    private var titleColor: String     = "#000000"
    private var titleColorDark: String = "#FFFFFF"
    private var msgColor: String       = "#000000"
    private var msgColorDark: String   = "#FFFFFF"

    private var lastLayoutSize: CGSize = .zero

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
    private let kRowHeight: CGFloat         = 100.0
    private let kShadowInset: CGFloat       = 3.0
    private let kBorderWidth: CGFloat       = 2.5

    // MARK: - Lifecycle

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        model = CTUtiltiy.loadContentData(data: data)

        if let bg     = model?.pt_bg,                  !bg.isEmpty     { bgColor          = bg }
        if let bgDark = model?.pt_bg_dark,             !bgDark.isEmpty { bgColorDark      = bgDark }
        if let border = model?.pt_small_icon_clr,      !border.isEmpty { borderColor      = border }
        if let bdDark = model?.pt_small_icon_clr_dark, !bdDark.isEmpty { borderColorDark  = bdDark }

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

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard view.bounds.size != lastLayoutSize else { return }
        lastLayoutSize = view.bounds.size

        applyCircularStyle()
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
            return max(min(computed, kRowHeight), 0)
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
                let wrapper = makeIconView(imageURL: item.imageURL, deepLink: item.deepLink)
                stackView.addArrangedSubview(wrapper)
                NSLayoutConstraint.activate([
                    wrapper.widthAnchor.constraint(equalToConstant: iconSize),
                    wrapper.heightAnchor.constraint(equalTo: wrapper.widthAnchor),
                ])
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

    private func makeIconView(imageURL: String, deepLink: String?) -> UIView {

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.backgroundColor    = .clear
        wrapper.layer.shadowColor   = UIColor.black.cgColor
        wrapper.layer.shadowOpacity = 0.18
        wrapper.layer.shadowRadius  = 5
        wrapper.layer.shadowOffset  = CGSize(width: 0, height: 2)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds     = true
        container.backgroundColor   = .clear
        container.layer.borderWidth = kBorderWidth
        container.layer.borderColor = cachedBorderColor.cgColor

        let imageView = UIImageView()
        imageView.contentMode  = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        wrapper.addSubview(container)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            container.topAnchor.constraint(equalTo: wrapper.topAnchor,            constant:  kShadowInset),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor,      constant: -kShadowInset),
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor,     constant:  kShadowInset),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor,   constant: -kShadowInset),
        ])

        let displayDiameter = kRowHeight - 2 * kShadowInset
        let targetSize = CGSize(width: displayDiameter, height: displayDiameter)
        let transformer = SDImageResizingTransformer(size: targetSize, scaleMode: .aspectFill)

        imageView.sd_setImage(
            with: URL(string: imageURL),
            placeholderImage: makePlaceholderImage(),
            options: [.retryFailed, .progressiveLoad],
            context: [.imageTransformer: transformer]
        )

        if let dl = deepLink, !dl.isEmpty {
            objc_setAssociatedObject(wrapper, &deepLinkKey, dl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            wrapper.isUserInteractionEnabled = true
            wrapper.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
            )
        }

        return wrapper
    }

    private func applyCircularStyle() {
        stackView.layoutIfNeeded()
        for wrapper in stackView.arrangedSubviews {
            guard let container = wrapper.subviews.first else { continue }
            container.layer.cornerRadius = container.bounds.width / 2
            wrapper.layer.shadowPath = UIBezierPath(ovalIn: container.frame).cgPath
        }
    }
    
    private func makePlaceholderImage() -> UIImage {
        let side: CGFloat = 60
        let size = CGSize(width: side, height: side)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIColor(white: 0.90, alpha: 1).setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()

            if #available(iOS 13.0, *),
               let symbol = UIImage(systemName: "photo")?
                   .withTintColor(UIColor(white: 0.55, alpha: 1), renderingMode: .alwaysOriginal) {
                let iconW: CGFloat = 26
                let iconH: CGFloat = 22
                symbol.draw(in: CGRect(x: (side - iconW) / 2,
                                       y: (side - iconH) / 2,
                                       width: iconW, height: iconH))
            }
        }
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
        let borderHex = isDarkMode ? borderColorDark : borderColor
        cachedBorderColor = UIColor(hex: borderHex) ?? .white
        cachedBgColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
    }

    func applyTheme() {
        view.backgroundColor = cachedBgColor

        titleLabel.textColor   = UIColor(hex: isDarkMode ? titleColorDark : titleColor)
        messageLabel.textColor = UIColor(hex: isDarkMode ? msgColorDark   : msgColor)

        let borderCGColor = cachedBorderColor.cgColor
        for wrapper in stackView.arrangedSubviews {
            wrapper.subviews.first?.layer.borderColor = borderCGColor
        }
    }

    // MARK: - BaseCTNotificationContentViewController

    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        return .doNotDismiss
    }

    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
