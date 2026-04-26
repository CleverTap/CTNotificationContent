import UIKit
import SDWebImage

@objc public class CTIconListViewController: BaseCTNotificationContentViewController {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""

    private var model: CTIconListModel?
    private var stackView: UIStackView = UIStackView()

    private var bgColor: String = ConstantKeys.kDefaultColor
    private var bgColorDark: String = ConstantKeys.kDefaultColorDark
    private var borderColor: String = "#CCCCCC"
    private var borderColorDark: String = "#CCCCCC"

    private let kHorizontalInset: CGFloat = 16.0
    private let kVerticalInset: CGFloat = 12.0
    private let kIconSpacing: CGFloat = 12.0
    private let kRowHeight: CGFloat = 100.0

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        model = CTUtiltiy.loadContentData(data: data)

        if let bg = model?.pt_bg, !bg.isEmpty { bgColor = bg }
        if let bgDark = model?.pt_bg_dark, !bgDark.isEmpty { bgColorDark = bgDark }
        if let border = model?.pt_small_icon_clr, !border.isEmpty { borderColor = border }
        if let borderDark = model?.pt_small_icon_clr_dark, !borderDark.isEmpty { borderColorDark = borderDark }

        applyTheme()
        setupIconRow()

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
                self.applyTheme()
            }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for container in stackView.arrangedSubviews {
            if let imageView = container.subviews.first(where: { $0 is UIImageView }) {
                imageView.layer.cornerRadius = imageView.bounds.width / 2
            }
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

    private func setupIconRow() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = kIconSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: kHorizontalInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kHorizontalInset),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: kVerticalInset),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -kVerticalInset),
        ])

        preferredContentSize = CGSize(width: view.bounds.width, height: kRowHeight)

        let items = (model?.iconItems ?? []).prefix(5)
        for item in items {
            let container = makeIconView(imageURL: item.imageURL, deepLink: item.deepLink)
            stackView.addArrangedSubview(container)
            container.heightAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        }
    }

    private func makeIconView(imageURL: String, deepLink: String?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = currentBorderColor().cgColor

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        if let url = URL(string: imageURL) {
            if #available(iOS 13.0, *) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle.fill"))
            } else {
                // Fallback on earlier versions
            }
        }

        if let deepLink = deepLink, !deepLink.isEmpty {
            container.accessibilityIdentifier = deepLink
            container.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
            container.addGestureRecognizer(tap)
        }

        return container
    }

    @objc private func handleIconTap(_ gesture: UITapGestureRecognizer) {
        guard let urlString = gesture.view?.accessibilityIdentifier,
              let url = URL(string: urlString) else { return }
        extensionContext?.open(url, completionHandler: nil)
    }

    private func currentBorderColor() -> UIColor {
        let isDark: Bool
        if #available(iOS 12.0, *) {
            isDark = traitCollection.userInterfaceStyle == .dark
        } else {
            isDark = false
        }
        return UIColor(hex: isDark ? borderColorDark : borderColor) ?? UIColor(hex: "#CCCCCC")!
    }

    func applyTheme() {
        let isDark: Bool
        if #available(iOS 12.0, *) {
            isDark = traitCollection.userInterfaceStyle == .dark
        } else {
            isDark = false
        }

        view.backgroundColor = UIColor(hex: isDark ? bgColorDark : bgColor)

        let borderCGColor = (UIColor(hex: isDark ? borderColorDark : borderColor) ?? UIColor(hex: "#CCCCCC")!).cgColor
        for container in stackView.arrangedSubviews {
            if let imageView = container.subviews.first(where: { $0 is UIImageView }) {
                imageView.layer.borderColor = borderCGColor
            }
        }
    }

    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        return .doNotDismiss
    }

    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
