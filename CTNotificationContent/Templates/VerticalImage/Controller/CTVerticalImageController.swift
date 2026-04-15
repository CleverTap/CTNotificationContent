//
//  CTVerticalImageController.swift
//  CTNotificationContent
//
//  Layout:
//  ┌──────────────┬──────────────────────────┐
//  │              │  Title (bold)            │
//  │  Portrait    │  Message (colored)       │
//  │  Image       │  Text1 (optional)        │
//  │              │  Text2 (optional)        │
//  │              │  [CTA Button] ←right col │
//  └──────────────┴──────────────────────────┘

import UIKit
import SDWebImage

@objc public class CTVerticalImageController: BaseCTNotificationContentViewController {

    // MARK: - Public Properties (set by ObjC router)
    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""

    // MARK: - Layout Constants
    /// Image occupies 38% of the notification width
    private let kImageWidthRatio: CGFloat = 0.38
    /// Portrait aspect ratio: height = width * (4/3)
    private let kImageAspectRatio: CGFloat = 4.0 / 3.0
    private let kOuterPadding: CGFloat = 10.0
    private let kColumnSpacing: CGFloat = 10.0
    private let kLabelSpacing: CGFloat = 8.0
    private let kButtonHeight: CGFloat = 44.0
    private let kButtonPadding: CGFloat = 8.0

    // MARK: - Color State
    var bgColor: String = ConstantKeys.kDefaultColor
    var bgColorDark: String = ConstantKeys.kDefaultColorDark
    var titleColor: String = ConstantKeys.kHexBlackColor
    var titleColorDark: String = ConstantKeys.kHexWhiteColor
    var msgColor: String = ConstantKeys.kHexLightGrayColor
    var msgColorDark: String = ConstantKeys.kHexDarkGrayColor
    var text1Color: String = ConstantKeys.kHexLightGrayColor
    var text1ColorDark: String = ConstantKeys.kHexDarkGrayColor
    var text2Color: String = ConstantKeys.kHexLightGrayColor
    var text2ColorDark: String = ConstantKeys.kHexDarkGrayColor
    var btnBgColor: String = ConstantKeys.kHexLightGrayColor
    var btnBgColorDark: String = ConstantKeys.kHexDarkGrayColor
    var btnTextColor: String = ConstantKeys.kHexWhiteColor
    var btnTextColorDark: String = ConstantKeys.kHexBlackColor

    // MARK: - Private State
    var jsonContent: VerticalImageProperties? = nil
    var bigImageAltText: String? = nil
    var buttonDeeplink: String = ""
    private var gradientButtonParams: (clr1: String, clr2: String, dir: String)?
    private var imageConstraintsActivated = false

    // MARK: - UI Elements

    /// Left column: portrait/vertical image
    private var bigImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.isAccessibilityElement = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var text1Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 1
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var text2Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 1
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// CTA button in the right column, pinned to bottom
    private var ctaButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    // MARK: - Lifecycle

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        setupConstraints()

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                    self.updateInterfaceColors()
                }
            }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientIfNeeded()
    }

    // MARK: - View Setup

    func createView() {
        setFrameWithoutImage()

        contentView.addSubview(bigImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(text1Label)
        contentView.addSubview(text2Label)
        contentView.addSubview(ctaButton)

        guard let json = jsonContent else { return }

        // Resolve title and message from payload or system notification fields
        if let title = json.pt_title, !title.isEmpty { templateCaption = title }
        if let msg = json.pt_msg, !msg.isEmpty { templateSubcaption = msg }
        if let summary = json.pt_msg_summary, !summary.isEmpty { templateSubcaption = summary }
        if let dl = json.pt_default_dl, !dl.isEmpty { deeplinkURL = dl }
        if let alt = json.pt_big_img_alt_text, !alt.isEmpty { bigImageAltText = alt }

        // Title — always shown (required field), anchored to top of right column
        titleLabel.text = templateCaption

        // Message — directly below title
        if !templateSubcaption.isEmpty {
            messageLabel.text = templateSubcaption
            if let clr = json.pt_msg_clr, !clr.isEmpty { msgColor = clr }
            if let clr = json.pt_msg_clr_dark, !clr.isEmpty { msgColorDark = clr }
        }

        // text1 and text2 — anchored to bottom of right column, above CTA button
        if let text1 = json.pt_text1, !text1.isEmpty {
            text1Label.text = text1
            text1Label.isHidden = false
            if let clr = json.pt_text1_clr, !clr.isEmpty { text1Color = clr }
            if let clr = json.pt_text1_clr_dark, !clr.isEmpty { text1ColorDark = clr }
        }
        if let text2 = json.pt_text2, !text2.isEmpty {
            text2Label.text = text2
            text2Label.isHidden = false
            if let clr = json.pt_text2_clr, !clr.isEmpty { text2Color = clr }
            if let clr = json.pt_text2_clr_dark, !clr.isEmpty { text2ColorDark = clr }
        }

        // CTA Button
        configureButton(json: json)

        // Background color
        if let bg = json.pt_bg, !bg.isEmpty { bgColor = bg }
        if let bgDark = json.pt_bg_dark, !bgDark.isEmpty { bgColorDark = bgDark }

        // Title color (optional override)
        if let clr = json.pt_title_clr, !clr.isEmpty { titleColor = clr }
        if let clr = json.pt_title_clr_dark, !clr.isEmpty { titleColorDark = clr }

        // Load image — GIF takes priority over static image
        if let gif = json.pt_gif, !gif.isEmpty, let url = URL(string: gif) {
            bigImageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
                DispatchQueue.main.async {
                    if image != nil {
                        self?.bigImageView.accessibilityLabel = json.pt_big_img_alt_text ?? CTAccessibility.kDefaultImageDescription
                        self?.configureScaleType(json.pt_scale_type)
                        self?.setFrameWithImage()
                    } else {
                        self?.loadStaticImage()
                    }
                }
            }
        } else {
            loadStaticImage()
        }

        updateInterfaceColors()
    }

    private func configureButton(json: VerticalImageProperties) {
        guard let btnName = json.pt_btn_name, !btnName.isEmpty else { return }

        ctaButton.setTitle(btnName, for: .normal)
        ctaButton.isHidden = false
        buttonDeeplink = json.pt_btn_dl ?? ""
        ctaButton.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)

        let btnStyle = json.pt_btn_style ?? "solid"

        // Store text color for dark mode updates
        if let textClr = json.pt_btn_text_clr, !textClr.isEmpty {
            btnTextColor = textClr
            btnTextColorDark = textClr
        }

        if btnStyle == "gradient_linear",
           let clr1 = json.pt_btn_grad_clr1, !clr1.isEmpty,
           let clr2 = json.pt_btn_grad_clr2, !clr2.isEmpty {
            // Gradient layer is applied in viewDidLayoutSubviews once bounds are known
            gradientButtonParams = (clr1: clr1, clr2: clr2, dir: json.pt_btn_grad_dir ?? "90")
        } else {
            // Solid button — store bg color for dark mode updates
            if let clr = json.pt_btn_clr, !clr.isEmpty {
                btnBgColor = clr
                btnBgColorDark = clr
            }
            if let borderClr = json.pt_btn_border_clr, !borderClr.isEmpty {
                ctaButton.layer.borderColor = UIColor(hex: borderClr)?.cgColor
                ctaButton.layer.borderWidth = 1.0
            }
        }
    }

    func setupConstraints() {
        // All constraints are image-dependent and activated in activateImageViewConstraints()
        // after the async image load completes and the frame is determined.
    }

    // MARK: - Frame Management

    func setFrameWithoutImage() {
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight()
        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }

    func setFrameWithImage() {
        let viewWidth = view.frame.size.width
        let imageWidth = viewWidth * kImageWidthRatio
        let imageHeight = imageWidth * kImageAspectRatio
        // Button sits inside the right column, so view height is driven by image height only
        let viewHeight = kOuterPadding + imageHeight + kOuterPadding

        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)

        activateImageViewConstraints(imageWidth: imageWidth, imageHeight: imageHeight)
    }

    // MARK: - Image Loading

    func loadStaticImage() {
        guard let imgUrl = jsonContent?.pt_big_img, !imgUrl.isEmpty else {
            showFallbackTextView()
            return
        }

        CTUtiltiy.checkImageUrlValid(imageUrl: imgUrl) { [weak self] (imageData) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let imageData = imageData {
                    self.bigImageView.image = imageData
                    self.bigImageView.accessibilityLabel = self.bigImageAltText ?? CTAccessibility.kDefaultImageDescription
                    self.configureScaleType(self.jsonContent?.pt_scale_type)
                    self.setFrameWithImage()
                } else {
                    self.showFallbackTextView()
                }
            }
        }
    }

    /// No image available — lay out all content full-width from the left and resize frame to fit.
    func showFallbackTextView() {
        let viewWidth = view.frame.size.width

        // Stack every visible element top-to-bottom, full width
        var constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: kOuterPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kOuterPadding),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kLabelSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kOuterPadding),
        ]

        var lastAnchor: NSLayoutYAxisAnchor = messageLabel.bottomAnchor

        if !text1Label.isHidden {
            constraints += [
                text1Label.topAnchor.constraint(equalTo: lastAnchor, constant: kLabelSpacing),
                text1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
                text1Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kOuterPadding),
            ]
            lastAnchor = text1Label.bottomAnchor
        }

        if !text2Label.isHidden {
            constraints += [
                text2Label.topAnchor.constraint(equalTo: lastAnchor, constant: kLabelSpacing),
                text2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
                text2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kOuterPadding),
            ]
            lastAnchor = text2Label.bottomAnchor
        }

        if !ctaButton.isHidden {
            constraints += [
                ctaButton.topAnchor.constraint(equalTo: lastAnchor, constant: kButtonPadding),
                ctaButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
                ctaButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kOuterPadding),
                ctaButton.heightAnchor.constraint(equalToConstant: kButtonHeight),
            ]
            lastAnchor = ctaButton.bottomAnchor
        }

        // Pin contentView bottom to last element so Auto Layout can compute exact height
        constraints.append(
            contentView.bottomAnchor.constraint(equalTo: lastAnchor, constant: kOuterPadding)
        )
        NSLayoutConstraint.activate(constraints)

        // Let Auto Layout compute exact height — avoids over-estimation from line-count guesses
        let fittedSize = contentView.systemLayoutSizeFitting(
            CGSize(width: viewWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let viewHeight = fittedSize.height

        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }

    func configureScaleType(_ scaleType: String?) {
        switch scaleType?.uppercased() {
        case "FIT_CENTER":
            bigImageView.contentMode = .scaleAspectFit
        default:
            bigImageView.contentMode = .scaleAspectFill
        }
    }

    // MARK: - Constraints

    func activateImageViewConstraints(imageWidth: CGFloat, imageHeight: CGFloat) {
        guard !imageConstraintsActivated else { return }
        imageConstraintsActivated = true

        let rightLeading = bigImageView.trailingAnchor
        let rightLeadingOffset = kColumnSpacing
        let rightTrailing = contentView.trailingAnchor
        let rightTrailingOffset = -kOuterPadding

        var allConstraints: [NSLayoutConstraint] = [
            // Left column: portrait image
            bigImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: kOuterPadding),
            bigImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kOuterPadding),
            bigImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            bigImageView.heightAnchor.constraint(equalToConstant: imageHeight),

            // Title: top of right column
            titleLabel.topAnchor.constraint(equalTo: bigImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: rightLeading, constant: rightLeadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: rightTrailing, constant: rightTrailingOffset),

            // Message: directly below title
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kLabelSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: rightLeading, constant: rightLeadingOffset),
            messageLabel.trailingAnchor.constraint(equalTo: rightTrailing, constant: rightTrailingOffset),
        ]

        // CTA button: bottom of right column
        if !ctaButton.isHidden {
            allConstraints += [
                ctaButton.bottomAnchor.constraint(equalTo: bigImageView.bottomAnchor),
                ctaButton.leadingAnchor.constraint(equalTo: rightLeading, constant: rightLeadingOffset),
                ctaButton.trailingAnchor.constraint(equalTo: rightTrailing, constant: rightTrailingOffset),
                ctaButton.heightAnchor.constraint(equalToConstant: kButtonHeight),
            ]
        }

        // text1 and text2: stacked just above the CTA button (or image bottom if no button)
        // text2 is immediately above the button; text1 is above text2
        let bottomAnchor = ctaButton.isHidden ? bigImageView.bottomAnchor : ctaButton.topAnchor
        let bottomOffset: CGFloat = ctaButton.isHidden ? -kOuterPadding : -kLabelSpacing

        if !text2Label.isHidden {
            allConstraints += [
                text2Label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomOffset),
                text2Label.leadingAnchor.constraint(equalTo: rightLeading, constant: rightLeadingOffset),
                text2Label.trailingAnchor.constraint(equalTo: rightTrailing, constant: rightTrailingOffset),
            ]
        }

        if !text1Label.isHidden {
            let text1Bottom = text2Label.isHidden ? bottomAnchor : text2Label.topAnchor
            let text1BottomOffset: CGFloat = text2Label.isHidden ? bottomOffset : -kLabelSpacing
            allConstraints += [
                text1Label.bottomAnchor.constraint(equalTo: text1Bottom, constant: text1BottomOffset),
                text1Label.leadingAnchor.constraint(equalTo: rightLeading, constant: rightLeadingOffset),
                text1Label.trailingAnchor.constraint(equalTo: rightTrailing, constant: rightTrailingOffset),
            ]
        }

        NSLayoutConstraint.activate(allConstraints)
    }

    // MARK: - Gradient Button

    @objc private func ctaButtonTapped() {
        if !buttonDeeplink.isEmpty, let url = URL(string: buttonDeeplink) {
            getParentViewController().open(url)
        } else {
            if #available(iOS 12.0, *) {
                extensionContext?.performNotificationDefaultAction()
            }
        }
    }

    private func applyGradientIfNeeded() {
        guard let params = gradientButtonParams,
              !ctaButton.isHidden,
              ctaButton.bounds.size.width > 0 else { return }

        ctaButton.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradLayer = CAGradientLayer()
        gradLayer.frame = ctaButton.bounds
        gradLayer.cornerRadius = ctaButton.layer.cornerRadius

        let c1 = UIColor(hex: params.clr1) ?? .clear
        let c2 = UIColor(hex: params.clr2) ?? .clear
        gradLayer.colors = [c1.cgColor, c2.cgColor]

        // Parse degree-based direction values like "15", "45", "90", etc.
        // Follows CSS linear-gradient convention: 0 = bottom-to-top, 90 = left-to-right.
        if let degrees = Double(params.dir.trimmingCharacters(in: .whitespaces)) {
            let radians = degrees * .pi / 180.0
            let endX = 0.5 + 0.5 * sin(radians)
            let endY = 0.5 - 0.5 * cos(radians)
            gradLayer.startPoint = CGPoint(x: 1.0 - endX, y: 1.0 - endY)
            gradLayer.endPoint   = CGPoint(x: endX, y: endY)
        } else {
            // Fallback: default to left-to-right (90 equivalent)
            gradLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        }

        ctaButton.layer.insertSublayer(gradLayer, at: 0)
    }

    // MARK: - Dark Mode

    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateInterfaceColors()
            }
        }
    }

    func updateInterfaceColors() {
        let isDarkMode: Bool
        if #available(iOS 12.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        } else {
            isDarkMode = false
        }

        view.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
        titleLabel.textColor = UIColor(hex: isDarkMode ? titleColorDark : titleColor)
        messageLabel.textColor = UIColor(hex: isDarkMode ? msgColorDark : msgColor)
        text1Label.textColor = UIColor(hex: isDarkMode ? text1ColorDark : text1Color)
        text2Label.textColor = UIColor(hex: isDarkMode ? text2ColorDark : text2Color)

        // CTA button — only applies to solid style; gradient buttons are handled via CAGradientLayer
        if gradientButtonParams == nil {
            let bgHex = isDarkMode ? btnBgColorDark : btnBgColor
            if !bgHex.isEmpty { ctaButton.backgroundColor = UIColor(hex: bgHex) }
        }
        let textHex = isDarkMode ? btnTextColorDark : btnTextColor
        ctaButton.setTitleColor(UIColor(hex: textHex) ?? .white, for: .normal)
    }

    // MARK: - Action Handling

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
