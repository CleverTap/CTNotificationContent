import UIKit
import UserNotificationsUI
import SDWebImage

@objc public class CTTimerTemplateController: BaseCTNotificationContentViewController {
    
    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    @objc public var notificationDeliveryDate: Date?

    var bgColor: String = ConstantKeys.kDefaultColor
    var captionColor: String = ConstantKeys.kHexBlackColor
    var subcaptionColor: String = ConstantKeys.kHexLightGrayColor
    // Dark mode colors
    var bgColorDark: String = ConstantKeys.kDefaultColorDark
    var captionColorDark: String = ConstantKeys.kHexWhiteColor
    var subcaptionColorDark: String = ConstantKeys.kHexDarkGrayColor
    
    var jsonContent: TimerTemplateProperties? = nil
    var timer: Timer = Timer()
    var thresholdSeconds = 0
    var bigImage: String = ""
    var bigImageAltText: String? = nil
    var bigImageAlt: String = ""
    var bigImageAltAltText: String? = nil
    private var imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.masksToBounds = true
        imageView.isAccessibilityElement = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textAlignment = .left
        captionLabel.adjustsFontSizeToFitWidth = false
        captionLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        captionLabel.textColor = UIColor.black
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        return captionLabel
    }()
    private var subcaptionLabel: UILabel = {
        let subcaptionLabel = UILabel()
        subcaptionLabel.textAlignment = .left
        subcaptionLabel.adjustsFontSizeToFitWidth = false
        subcaptionLabel.font = UIFont.systemFont(ofSize: 12.0)
        subcaptionLabel.textColor = UIColor.lightGray
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return subcaptionLabel
    }()
    private var timerBoxView: CTTimerBoxView?
    private var captionTrailingConstraint: NSLayoutConstraint?
    private var subcaptionTrailingConstraint: NSLayoutConstraint?

    private func setTruncatingHTMLText(_ text: String, on label: UILabel) {
        label.setHTMLText(text)
        label.lineBreakMode = .byTruncatingTail
    }

    private func setTimerText(_ text: String) {
        timerBoxView?.timerLabel.text = text
    }

    private func hideTimerDisplay() {
        timerBoxView?.isHidden = true
        captionTrailingConstraint?.constant = -Constraints.kCaptionLeftPadding
        subcaptionTrailingConstraint?.constant = -Constraints.kCaptionLeftPadding
    }

    private func timerReservedWidth(showHours: Bool) -> CGFloat {
        let base = showHours ? Constraints.kTimerLabelWidthWithHours : Constraints.kTimerLabelWidth
        let borderWidth = jsonContent?.pt_chrono_border_width
            .map { min(CGFloat($0.value), Constraints.kTimerBorderMaxWidth) } ?? 0
        return base + 2 * borderWidth
    }

    private func updateTimerWidthIfNeeded(showHours: Bool) {
        let newWidth = timerReservedWidth(showHours: showHours)
        guard captionTrailingConstraint?.constant != -newWidth else { return }
        captionTrailingConstraint?.constant = -newWidth
        subcaptionTrailingConstraint?.constant = -newWidth
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }
    }

    private func isDarkMode() -> Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        return false
    }

    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        setupConstraints()
        
        // Register for trait changes on iOS 17+
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                    self.updateInterfaceColors()
                }
            }
        }
    }
    
    @objc public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func createView() {
        createFrameWithoutImage()
        contentView.addSubview(imageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(subcaptionLabel)

        let box = CTTimerBoxView()
        timerBoxView = box
        contentView.addSubview(box)

        setTruncatingHTMLText(templateCaption, on: captionLabel)
        setTruncatingHTMLText(templateSubcaption, on: subcaptionLabel)

        guard let jsonContent = jsonContent else {
            CTContentLog.error("Nil payload data, rendering caption only")
            return
        }
        if let threshold = jsonContent.pt_timer_threshold {
            if let deliveredAt = notificationDeliveryDate {
                let elapsed = Int(Date().timeIntervalSince(deliveredAt))
                thresholdSeconds = max(0, threshold - elapsed)
                CTContentLog.info("Using pt_timer_threshold=\(threshold), deliveredAt=\(Int(deliveredAt.timeIntervalSince1970)), elapsed=\(elapsed)")
            } else {
                thresholdSeconds = threshold
                CTContentLog.error("Nil notificationDeliveryDate, using pt_timer_threshold=\(threshold) without subtracting elapsed time")
            }
        } else if let endTime = jsonContent.pt_timer_end {
            let currentTime = Date().timeIntervalSince1970
            thresholdSeconds = endTime - Int(currentTime)
            CTContentLog.info("Using pt_timer_end=\(endTime), now=\(Int(currentTime))")
        } else {
            CTContentLog.error("Missing pt_timer_threshold and pt_timer_end, starting at 0, rendering expired state")
        }
        CTContentLog.info("Timer controller started, secondsLeft=\(thresholdSeconds)")

        if let title = jsonContent.pt_title, !title.isEmpty {
            setTruncatingHTMLText(title, on: captionLabel)
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty {
            setTruncatingHTMLText(msg, on: subcaptionLabel)
        }
        if let msgSummary = jsonContent.pt_msg_summary, !msgSummary.isEmpty {
            setTruncatingHTMLText(msgSummary, on: subcaptionLabel)
        }
        if let bg = jsonContent.pt_bg, !bg.isEmpty {
            bgColor = bg
        }
        if let titleColor = jsonContent.pt_title_clr, !titleColor.isEmpty {
            captionColor = titleColor
        }
        if let msgColor = jsonContent.pt_msg_clr, !msgColor.isEmpty {
            subcaptionColor = msgColor
        }
        // Handle dark mode colors
        if let bgDark = jsonContent.pt_bg_dark, !bgDark.isEmpty {
            bgColorDark = bgDark
        }
        if let titleColorDark = jsonContent.pt_title_clr_dark, !titleColorDark.isEmpty {
            captionColorDark = titleColorDark
        }
        if let msgColorDark = jsonContent.pt_msg_clr_dark, !msgColorDark.isEmpty {
            subcaptionColorDark = msgColorDark
        }
        if let action = jsonContent.pt_dl1, !action.isEmpty {
            deeplinkURL = action
        }
        if let bigImg = jsonContent.pt_big_img, !bigImg.isEmpty {
            bigImage = bigImg
        }
        if let bigImgAlt = jsonContent.pt_big_img_alt_text, !bigImgAlt.isEmpty {
            bigImageAltText = bigImgAlt
        }
        
        if thresholdSeconds <= 0 {
            hideTimerDisplay()
        }

        updateInterfaceColors()

        if let box = timerBoxView {
            box.applyStyle(properties: jsonContent, isDarkMode: isDarkMode())
        }

        // Handle image loading
        // Load image only if timer is not ended.
        if thresholdSeconds > 0 {
            if let gif = jsonContent.pt_gif, !gif.isEmpty, let url = URL(string: gif) {
                CTContentLog.info("Loading gif, url=\(gif)")
                self.imageView.sd_setImage(with: url, completed: { [weak self] (image, error, _, _) in
                    guard let self = self else {
                        CTContentLog.error("Controller deallocated before gif arrived")
                        return
                    }
                    guard image != nil else {
                        CTContentLog.error("Gif load failed, falling back to still image, url=\(gif), error=\(error?.localizedDescription ?? "nil image, no error")")
                        self.showImageView()
                        return
                    }
                    self.imageView.accessibilityLabel = jsonContent.pt_big_img_alt_text ?? CTAccessibility.kDefaultImageDescription
                    self.activateImageViewContraints()
                    self.createFrameWithImage()
                })
            } else {
                if let gif = jsonContent.pt_gif, !gif.isEmpty {
                    CTContentLog.error("Gif url parse failed, falling back to still image, url=\(gif)")
                }
                self.showImageView()
            }
        } else {
            CTContentLog.info("Timer already expired, skipping running state image load")
        }
    }
    
    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handle trait changes, for iOS 17+ it is handled by registerForTraitChanges.
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateInterfaceColors()
            }
        }
    }
    
    func updateInterfaceColors() {
        // Check if device is in dark mode (iOS 12+)
        let isDarkMode: Bool
        
        if #available(iOS 12.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        } else {
            // For iOS versions before 12.0,using light mode colors since dark mode wasn't officially supported
            isDarkMode = false
        }
        
        view.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
        imageView.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
        captionLabel.textColor = UIColor(hex: isDarkMode ? captionColorDark : captionColor)
        subcaptionLabel.textColor = UIColor(hex: isDarkMode ? subcaptionColorDark : subcaptionColor)

        if let box = timerBoxView, let props = jsonContent {
            box.applyStyle(properties: props, isDarkMode: isDarkMode)
        }
    }

    func setupConstraints() {
        guard let activeTimerView: UIView = timerBoxView else {
            CTContentLog.error("Nil timer box view, skipping timer layout")
            return
        }
        let initialTrailingConstant: CGFloat = thresholdSeconds > 0
            ? -timerReservedWidth(showHours: thresholdSeconds > 3600)
            : -Constraints.kCaptionLeftPadding
        let captionTrailing = captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: initialTrailingConstant)
        let subcaptionTrailing = subcaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: initialTrailingConstant)
        captionTrailingConstraint = captionTrailing
        subcaptionTrailingConstraint = subcaptionTrailing

        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() - Constraints.kCaptionTopPadding)),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            captionTrailing,
            captionLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),

            subcaptionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(Constraints.kSubCaptionHeight + Constraints.kSubCaptionTopPadding)),
            subcaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subcaptionTrailing,
            subcaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight),

            activeTimerView.centerYAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() / 2)),
            activeTimerView.leadingAnchor.constraint(equalTo: captionLabel.trailingAnchor, constant: Constraints.kTimerHorizontalGap),
            activeTimerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            activeTimerView.heightAnchor.constraint(equalToConstant: Constraints.kTimerBoxHeight)
        ])
    }

    @objc func updateTimer() {
        let hr = thresholdSeconds / 3600
        let min = thresholdSeconds / 60 % 60
        let sec = thresholdSeconds % 60
        // One line per second. That is too much for the normal logs. It shows
        // whether the countdown really runs, and at what speed.
        CTContentLog.debug("Tick, secondsLeft=\(thresholdSeconds)")
        if thresholdSeconds > 0 {
            if hr < 1 {
                setTimerText(String(format: "%02i:%02i", min, sec))
                updateTimerWidthIfNeeded(showHours: false)
            } else {
                setTimerText(String(format: "%02i:%02i:%02i", hr, min, sec))
                updateTimerWidthIfNeeded(showHours: true)
            }
            thresholdSeconds -= 1
        } else {
            timer.invalidate()
            hideTimerDisplay()
            updateViewForExpiredTime()
        }
    }
    
    func updateViewForExpiredTime() {
        guard let jsonContent = jsonContent else {
            CTContentLog.error("Timer expired but payload data is nil, leaving view unchanged")
            return
        }
        CTContentLog.info("Timer expired, rendering expired texts and image")
        if let title = jsonContent.pt_title_alt, !title.isEmpty {
            setTruncatingHTMLText(title, on: captionLabel)
        }
        if let msg = jsonContent.pt_msg_alt, !msg.isEmpty {
            setTruncatingHTMLText(msg, on: subcaptionLabel)
        }
        if let bigImgAlt = jsonContent.pt_big_img_alt, !bigImgAlt.isEmpty {
            bigImageAlt = bigImgAlt
        }
        if let bigImgAltAlt = jsonContent.pt_big_img_alt_alt_text, !bigImgAltAlt.isEmpty {
            bigImageAltAltText = bigImgAltAlt
        }
        if let gifAlt = jsonContent.pt_gif_alt, !gifAlt.isEmpty, let url = URL(string: gifAlt) {
            CTContentLog.info("Loading expired gif, url=\(gifAlt)")
            CTUtiltiy.checkImageUrlValid(imageUrl: gifAlt) { [weak self] (imageData) in
                // The callback runs off the main thread. Every view call below
                // has to be made on the main thread.
                DispatchQueue.main.async {
                    guard let self = self else {
                        CTContentLog.error("Controller deallocated before expired gif was checked")
                        return
                    }
                    guard imageData != nil else {
                        CTContentLog.error("Expired gif unreachable, falling back to expired still image, url=\(gifAlt)")
                        self.showAltImageView()
                        return
                    }
                    self.showAltGifView(url)
                }
            }
        } else {
            if let gifAlt = jsonContent.pt_gif_alt, !gifAlt.isEmpty {
                CTContentLog.error("Expired gif url parse failed, falling back to expired still image, url=\(gifAlt)")
            }
            self.showAltImageView()
        }

        updateInterfaceColors()
    }
    
    func createFrameWithoutImage() {
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }

    func createFrameWithImage() {
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + CTUtiltiy.getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + CTUtiltiy.getCaptionHeight()

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    
    func activateImageViewContraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constraints.kImageBorderWidth),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CTUtiltiy.getCaptionHeight())
        ])
    }
    
    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if deeplinkURL.isEmpty {
                CTContentLog.info("No deeplink, dismissing")
            } else if let url = URL(string: deeplinkURL) {
                CTContentLog.info("Opening deeplink, url=\(deeplinkURL)")
                getParentViewController()?.open(url)
            } else {
                CTContentLog.error("Deeplink parse failed, url=\(deeplinkURL)")
            }
            return .dismiss
        }
        return .doNotDismiss
    }
    
    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
    
    func showImageView() {
        guard !bigImage.isEmpty else {
            CTContentLog.info("Missing pt_big_img, rendering caption only")
            return
        }
        CTUtiltiy.checkImageUrlValid(imageUrl: bigImage) { [weak self] (imageData) in
            DispatchQueue.main.async {
                guard let self = self else {
                    CTContentLog.error("Controller deallocated before image arrived")
                    return
                }
                guard imageData != nil else {
                    CTContentLog.error("Image load failed, rendering caption only, url=\(self.bigImage)")
                    return
                }
                CTContentLog.info("Image rendered, url=\(self.bigImage)")
                self.imageView.image = imageData
                self.imageView.accessibilityLabel = self.bigImageAltText ?? CTAccessibility.kDefaultImageDescription
                self.activateImageViewContraints()
                self.createFrameWithImage()
            }
        }
    }

    func showAltGifView(_ url: URL) {
        self.imageView.sd_setImage(with: url, completed: { [weak self] (image, error, _, _) in
            guard let self = self else {
                CTContentLog.error("Controller deallocated before expired gif arrived")
                return
            }
            guard image != nil else {
                CTContentLog.error("Expired gif load failed, falling back to expired still image, url=\(url.absoluteString), error=\(error?.localizedDescription ?? "nil image, no error")")
                self.showAltImageView()
                return
            }
            CTContentLog.info("Expired gif rendered")
            self.imageView.accessibilityLabel = self.bigImageAltAltText ?? CTAccessibility.kDefaultImageDescription
            self.createFrameWithImage()
            self.activateImageViewContraints()
        })
    }

    func showAltImageView() {
        guard !bigImageAlt.isEmpty else {
            CTContentLog.info("Missing pt_big_img_alt, keeping image already on screen")
            return
        }
        // Load expired image, if available.
        CTUtiltiy.checkImageUrlValid(imageUrl: bigImageAlt) { [weak self] (imageData) in
            DispatchQueue.main.async {
                guard let self = self else {
                    CTContentLog.error("Controller deallocated before expired image arrived")
                    return
                }
                guard imageData != nil else {
                    CTContentLog.error("Expired image load failed, keeping image already on screen, url=\(self.bigImageAlt)")
                    return
                }
                CTContentLog.info("Expired image rendered, url=\(self.bigImageAlt)")
                self.imageView.image = imageData
                self.imageView.accessibilityLabel = self.bigImageAltAltText ?? CTAccessibility.kDefaultImageDescription
                self.createFrameWithImage()
                self.activateImageViewContraints()
            }
        }
    }
}
