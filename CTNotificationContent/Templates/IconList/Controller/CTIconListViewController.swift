import UIKit
import SDWebImage
import ObjectiveC

private var deepLinkKey: UInt8 = 0

@objc public class CTIconListViewController: BaseCTNotificationContentViewController {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""

    private var model: CTIconListModel?
    private var stackView: UIStackView = UIStackView()

    // Payload-driven colours
    private var bgColor: String = ConstantKeys.kDefaultColor
    private var bgColorDark: String = ConstantKeys.kDefaultColorDark
    private var borderColor: String = "#FFFFFF"
    private var borderColorDark: String = "#FFFFFF"

    // Layout constants
    private let kHorizontalPadding: CGFloat = 16.0
    private let kVerticalPadding: CGFloat   = 10.0
    private let kIconSpacing: CGFloat       = 10.0
    private let kRowHeight: CGFloat         = 100.0
    private let kShadowInset: CGFloat       = 3.0
    
    // MARK: - Lifecycle

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        model = CTUtiltiy.loadContentData(data: data)

        if let bg     = model?.pt_bg,               !bg.isEmpty     { bgColor      = bg }
        if let bgDark = model?.pt_bg_dark,           !bgDark.isEmpty { bgColorDark  = bgDark }
        if let border = model?.pt_small_icon_clr,    !border.isEmpty { borderColor  = border }
        if let bdDark = model?.pt_small_icon_clr_dark, !bdDark.isEmpty { borderColorDark = bdDark }

        setupIconRow()
        applyTheme()

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
                self.applyTheme()
            }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for wrapper in stackView.arrangedSubviews {
            guard let container = wrapper.subviews.first else { continue }
            container.layer.cornerRadius = container.bounds.width / 2
            wrapper.layer.shadowPath = UIBezierPath(ovalIn: container.frame).cgPath
        }
    }

    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 17.0, *) { return }
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                applyTheme()
            }
        }
    }

    // MARK: - Row Setup

    private func setupIconRow() {
        stackView.axis        = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment   = .center
        stackView.spacing     = kIconSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,  constant:  kHorizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalPadding),
            stackView.topAnchor.constraint(equalTo: view.topAnchor,          constant:  kVerticalPadding),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor,    constant: -kVerticalPadding),
        ])

        preferredContentSize = CGSize(width: view.bounds.width, height: kRowHeight)

        for item in (model?.iconItems ?? []).prefix(5) {
            let wrapper = makeIconView(imageURL: item.imageURL, deepLink: item.deepLink)
            stackView.addArrangedSubview(wrapper)
            wrapper.heightAnchor.constraint(equalTo: wrapper.widthAnchor).isActive = true
        }
    }

    // MARK: - Icon View Factory

    private func makeIconView(imageURL: String, deepLink: String?) -> UIView {

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.backgroundColor = .clear
        wrapper.layer.shadowColor   = UIColor.black.cgColor
        wrapper.layer.shadowOpacity = 0.18
        wrapper.layer.shadowRadius  = 5
        wrapper.layer.shadowOffset  = CGSize(width: 0, height: 2)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds  = true
        container.backgroundColor    = .white
        container.layer.borderWidth  = 2
        container.layer.borderColor  = currentBorderColor().cgColor

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        wrapper.addSubview(container)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            container.topAnchor.constraint(equalTo: wrapper.topAnchor,       constant:  kShadowInset),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -kShadowInset),
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor,  constant:  kShadowInset),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -kShadowInset),
        ])

        imageView.sd_setImage(with: URL(string: imageURL),
                              placeholderImage: makePlaceholderImage())

        if let dl = deepLink, !dl.isEmpty {
            objc_setAssociatedObject(wrapper, &deepLinkKey, dl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            wrapper.isUserInteractionEnabled = true
            wrapper.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
            )
        }

        return wrapper
    }

    // MARK: - Placeholder

    private func makePlaceholderImage() -> UIImage {
        let side: CGFloat = 60
        let bounds = CGRect(origin: .zero, size: CGSize(width: side, height: side))
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            UIColor(white: 0.90, alpha: 1).setFill()
            UIBezierPath(ovalIn: bounds).fill()

            let iconColor = UIColor(white: 0.55, alpha: 1)
            if #available(iOS 13.0, *),
               let symbol = UIImage(systemName: "photo")?
                   .withTintColor(iconColor, renderingMode: .alwaysOriginal) {
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

    // MARK: - Theming

    private var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        return false
    }

    private func currentBorderColor() -> UIColor {
        let hex = isDarkMode ? borderColorDark : borderColor
        return UIColor(hex: hex) ?? .white
    }

    func applyTheme() {
        view.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)

        let borderCGColor = currentBorderColor().cgColor
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
