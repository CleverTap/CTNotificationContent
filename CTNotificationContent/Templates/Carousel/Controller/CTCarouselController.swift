import UIKit
import UserNotificationsUI

@objc public class CTCarouselController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var pageControl: UIPageControl = UIPageControl(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    var timer: Timer? = nil
    var itemViews =  [CTCaptionedImageView]()
    var currentItemIndex: Int = 0
    @objc public var data: String = ""
    @objc public var templateType: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    @objc public var isFromProductDisplay: Bool = false

    var bgColor: String = ConstantKeys.kDefaultColor
    var captionColor: String = ConstantKeys.kHexBlackColor
    var subcaptionColor: String = ConstantKeys.kHexLightGrayColor
    
    // Dark mode colors
    var bgColorDark: String = ConstantKeys.kDefaultColorDark
    var captionColorDark: String = ConstantKeys.kHexWhiteColor
    var subcaptionColorDark: String = ConstantKeys.kHexDarkGrayColor

    var jsonContent: CarouselProperties? = nil
    var nextButtonImage: UIImage = UIImage()
    var previousButtonImage: UIImage = UIImage()
    var nextButton: UIButton = UIButton(frame: .zero)
    var previousButton: UIButton = UIButton(frame: .zero)
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        let recognizer1 = UITapGestureRecognizer(target: self, action: #selector(openDeeplink))
        contentView.addGestureRecognizer(recognizer1)
        
        CTContentLog.info("Carousel controller started, templateType=\(templateType), fromProductDisplay=\(isFromProductDisplay)")
        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        
        // Register for trait changes on iOS 17+
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                    self.updateContentViewBackground()
                }
            }
        }
    }
    
    func createView() {
        guard let jsonContent = jsonContent else {
            // Show default alert view and update constraints when json data is not available.
            CTContentLog.error("Nil payload data, rendering caption only")
            setUpConstraints()
            return
        }

        if let title = jsonContent.pt_title, !title.isEmpty {
            templateCaption = title
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty {
            templateSubcaption = msg
        }
        if let msgSummary = jsonContent.pt_msg_summary, !msgSummary.isEmpty {
            templateSubcaption = msgSummary
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
        var actionUrl = deeplinkURL
        if let deeplink = jsonContent.pt_dl1, !deeplink.isEmpty {
            actionUrl = deeplink
        }
        deeplinkURL = actionUrl
        updateContentViewBackground()

        if templateType == TemplateConstants.kTemplateBasic {
            var basicImageDetails: (url: String, description: String?) = ("", nil)
            var basicGifDetails: (url: String, description: String?) = ("", nil)
            if let url = jsonContent.pt_big_img, !url.isEmpty {
                basicImageDetails = (url: url, description: jsonContent.pt_big_img_alt_text)
            }else if isFromProductDisplay{
                //case for handling image data for product display
                if let url = jsonContent.pt_img1, !url.isEmpty {
                    basicImageDetails = (url: url, description: jsonContent.pt_img1_alt_text)
                }else if let url = jsonContent.pt_img2, !url.isEmpty {
                    basicImageDetails = (url: url, description: jsonContent.pt_img2_alt_text)
                }else if let url = jsonContent.pt_img3, !url.isEmpty {
                    basicImageDetails = (url: url, description: jsonContent.pt_img3_alt_text)
                }
            }
            if let gifURL = jsonContent.pt_gif, !gifURL.isEmpty {
                basicGifDetails = (url: gifURL, description: jsonContent.pt_big_img_alt_text)
            }

            CTUtiltiy.checkImageUrlValid(imageUrl: basicGifDetails.url) { [weak self] (gifData) in
                if gifData == nil {
                    CTUtiltiy.checkImageUrlValid(imageUrl: basicImageDetails.url) { [weak self] (imageData) in
                        DispatchQueue.main.async {
                            guard let self = self else {
                                CTContentLog.error("Controller deallocated before image arrived")
                                return
                            }
                            if imageData != nil {
                                let itemComponents = CaptionedImageViewComponents(caption: self.templateCaption, subcaption: self.templateSubcaption, imageUrl: basicImageDetails.url, actionUrl: actionUrl, bgColor: self.bgColor, captionColor: self.captionColor, subcaptionColor: self.subcaptionColor, bgColorDark: self.bgColorDark, captionColorDark: self.captionColorDark, subcaptionColorDark: self.subcaptionColorDark, imageDescription: basicImageDetails.description ?? CTAccessibility.kDefaultImageDescription)
                                let itemView = CTCaptionedImageView(components: itemComponents, isGifSupported: true)
                                self.itemViews.append(itemView)
                                CTContentLog.info("Basic template rendering image, url=\(basicImageDetails.url)")
                            } else {
                                CTContentLog.error("Image load failed, rendering caption only")
                            }
                            self.setUpConstraints()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        guard let self = self else {
                            CTContentLog.error("Controller deallocated before gif arrived")
                            return
                        }
                        let itemComponents = CaptionedImageViewComponents(caption: self.templateCaption, subcaption: self.templateSubcaption, imageUrl: basicGifDetails.url, actionUrl: actionUrl, bgColor: self.bgColor, captionColor: self.captionColor, subcaptionColor: self.subcaptionColor, bgColorDark: self.bgColorDark, captionColorDark: self.captionColorDark, subcaptionColorDark: self.subcaptionColorDark, imageDescription: basicGifDetails.description ?? CTAccessibility.kDefaultImageDescription)
                        let itemView = CTCaptionedImageView(components: itemComponents, isGifSupported: true)
                        self.itemViews.append(itemView)
                        CTContentLog.info("Basic template rendering gif, url=\(basicGifDetails.url)")
                        self.setUpConstraints()
                    }
                }
            }
        } else if templateType == TemplateConstants.kTemplateAutoCarousel || templateType == TemplateConstants.kTemplateManualCarousel {
            var imageUrls = [(url: String, description: String?, deeplink: String)]()
            if let url = jsonContent.pt_img1, !url.isEmpty {
                imageUrls.append((url: url, description: jsonContent.pt_img1_alt_text, deeplink: resolveDeeplink(jsonContent.pt_dl1, fallback: actionUrl)))
            }
            if let url = jsonContent.pt_img2, !url.isEmpty {
                imageUrls.append((url: url, description: jsonContent.pt_img2_alt_text, deeplink: resolveDeeplink(jsonContent.pt_dl2, fallback: actionUrl)))
            }
            if let url = jsonContent.pt_img3, !url.isEmpty {
                imageUrls.append((url: url, description: jsonContent.pt_img3_alt_text, deeplink: resolveDeeplink(jsonContent.pt_dl3, fallback: actionUrl)))
            }

            if imageUrls.isEmpty {
                CTContentLog.error("No image urls in payload, rendering caption only")
            } else {
                CTContentLog.info("Loading \(imageUrls.count) carousel images")
            }

            let dispatchGroup = DispatchGroup()
            var orderedItemViews = [Int: CTCaptionedImageView]()
            for (index, imageDetails) in imageUrls.enumerated() {
                dispatchGroup.enter()
                CTUtiltiy.checkImageUrlValid(imageUrl: imageDetails.url) { [weak self] (imageData) in
                    DispatchQueue.main.async {
                        defer { dispatchGroup.leave() }
                        guard let self = self else {
                            CTContentLog.error("Controller deallocated before image \(index + 1) arrived")
                            return
                        }
                        guard imageData != nil else {
                            CTContentLog.error("Skipping image \(index + 1), load failed, url=\(imageDetails.url)")
                            return
                        }
                        let itemComponents = CaptionedImageViewComponents(caption: self.templateCaption, subcaption: self.templateSubcaption, imageUrl: imageDetails.url, actionUrl: imageDetails.deeplink, bgColor: self.bgColor, captionColor: self.captionColor, subcaptionColor: self.subcaptionColor, bgColorDark: self.bgColorDark, captionColorDark: self.captionColorDark, subcaptionColorDark: self.subcaptionColorDark, imageDescription: imageDetails.description ?? "\(CTAccessibility.kDefaultImageDescription) \(index + 1)")
                        orderedItemViews[index] = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
                    }
                }
            }
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let self = self else {
                    CTContentLog.error("Controller deallocated before images arrived")
                    return
                }
                self.itemViews = (0..<imageUrls.count).compactMap { orderedItemViews[$0] }
                CTContentLog.info("Loaded \(self.itemViews.count)/\(imageUrls.count) carousel images")
                self.setUpConstraints()
            }
        }
    }
    
    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handle trait changes, for iOS 17+ it is handled by registerForTraitChanges.
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateContentViewBackground()
            }
        }
    }
    
    func updateContentViewBackground() {
        // Check if device is in dark mode (iOS 12+)
        let isDarkMode: Bool
        
        if #available(iOS 12.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        } else {
            // For iOS versions before 12.0,using light mode colors since dark mode wasn't officially supported
            isDarkMode = false
        }
        
        contentView.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
    }
    
    func setUpConstraints() {
        if itemViews.count == 0 {
            // Add default alert view if no image is downloaded.
            createDefaultAlertView()
            createFrameWithoutImage()
        } else {
            createFrameWithImage()
        }
        
        for subView in itemViews {
            subView.superview?.removeFromSuperview()
        }
        guard !itemViews.isEmpty else {
            CTContentLog.error("No item views to render")
            return
        }
        // itemViews can shrink between two calls, so the index is brought back
        // into range before it is used.
        if currentItemIndex < 0 || currentItemIndex >= itemViews.count {
            CTContentLog.error("Index \(currentItemIndex) out of range for \(itemViews.count) items, resetting to 0")
            currentItemIndex = 0
        }
        currentItemView = itemViews[currentItemIndex]
        contentView.addSubview(currentItemView)
        currentItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            currentItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            currentItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currentItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // Show other view elements if image downloaded is more than 1
        if itemViews.count > 1 {
            pageControl.numberOfPages = itemViews.count
            pageControl.hidesForSinglePage = true
            view.addSubview(pageControl)
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageControl.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() + Constraints.kPageControlViewHeight)),
                pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                pageControl.heightAnchor.constraint(equalToConstant: Constraints.kPageControlViewHeight)
            ])
            
            if templateType == TemplateConstants.kTemplateAutoCarousel {
                startAutoPlay()
            } else if templateType == TemplateConstants.kTemplateManualCarousel {
                // TODO: Unhide buttons when user interaction will be added.
//                nextButton.isHidden = true
//                previousButton.isHidden = true

                
                // Show Next and Previous button for manual carousel.
                let bundle = Bundle(for: type(of: self))
                if let image = UIImage(named: "ct_next_button", in: bundle, compatibleWith: nil) {
                    nextButtonImage = image
                } else {
                    CTContentLog.error("Missing bundle asset ct_next_button, next button has no icon")
                }
                nextButton.setImage(nextButtonImage, for: .normal)
                nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
                nextButton.accessibilityLabel = "Next image"
                nextButton.accessibilityHint = "Shows the next image in the carousel"
                nextButton.accessibilityTraits = .button
                nextButton.accessibilityIdentifier = CTAccessibility.kCarouselNextButtonIdentifier

                if let image = UIImage(named: "ct_previous_button", in: bundle, compatibleWith: nil) {
                    previousButtonImage = image
                } else {
                    CTContentLog.error("Missing bundle asset ct_previous_button, previous button has no icon")
                }
                previousButton.setImage(previousButtonImage, for: .normal)
                previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
                previousButton.accessibilityLabel = "Previous image"
                previousButton.accessibilityHint = "Shows the previous image in the carousel"
                previousButton.accessibilityTraits = .button
                previousButton.accessibilityIdentifier = CTAccessibility.kCarouselPreviousButtonIdentifier

                contentView.addSubview(nextButton)
                contentView.addSubview(previousButton)
                nextButton.translatesAutoresizingMaskIntoConstraints = false
                previousButton.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    nextButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100.0),
                    nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5.0),
                    nextButton.heightAnchor.constraint(equalToConstant: 40.0),
                    nextButton.widthAnchor.constraint(equalToConstant: 40.0),

                    previousButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100.0),
                    previousButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
                    previousButton.heightAnchor.constraint(equalToConstant: 40.0),
                    previousButton.widthAnchor.constraint(equalToConstant: 40.0)
                ])
                contentView.bringSubviewToFront(nextButton)
                contentView.bringSubviewToFront(previousButton)
            }
        }
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
    
    func createDefaultAlertView() {
        let itemComponents = CaptionedImageViewComponents(caption: templateCaption, subcaption: templateSubcaption, imageUrl: "", actionUrl: deeplinkURL, bgColor: bgColor, captionColor: captionColor, subcaptionColor: subcaptionColor, bgColorDark: bgColorDark, captionColorDark: captionColorDark, subcaptionColorDark: subcaptionColorDark, imageDescription: "")
        let itemView = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
        itemViews.append(itemView)
    }
    
    @objc func nextButtonTapped() {
        showNext()
    }
    
    @objc func previousButtonTapped() {
        showPrevious()
    }

    /// Deeplink of the image on screen. Empty when there is no image.
    private var currentActionUrl: String {
        guard currentItemIndex >= 0, currentItemIndex < itemViews.count else {
            CTContentLog.error("No item at index \(currentItemIndex)/\(itemViews.count), no deeplink available")
            return ""
        }
        return itemViews[currentItemIndex].components.actionUrl
    }

    @objc func openDeeplink() {
        let urlString = currentActionUrl
        if urlString.isEmpty {
            CTContentLog.info("Tap with no deeplink at index=\(currentItemIndex), performing notification default action")
            if #available(iOS 12.0, *) {
                self.extensionContext?.performNotificationDefaultAction()
            }
            return
        }
        guard let url = URL(string: urlString) else {
            CTContentLog.error("Deeplink parse failed, index=\(currentItemIndex), url=\(urlString)")
            return
        }
        CTContentLog.info("Tap, opening deeplink, index=\(currentItemIndex), url=\(urlString)")
        getParentViewController()?.open(url)
    }
    
    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction1 {
            // Maps to show previous
            if templateType == TemplateConstants.kTemplateManualCarousel {
                showPrevious()
            }
        } else if action == ConstantKeys.kAction2 {
            // Maps to show next
            if templateType == TemplateConstants.kTemplateManualCarousel {
                showNext()
            }
        } else if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if itemViews.count > 0 {
                let urlString = currentActionUrl
                if urlString.isEmpty {
                    CTContentLog.info("No deeplink at index=\(currentItemIndex), dismissing")
                } else if let url = URL(string: urlString) {
                    CTContentLog.info("Opening deeplink, index=\(currentItemIndex), url=\(urlString)")
                    getParentViewController()?.open(url)
                } else {
                    CTContentLog.error("Deeplink parse failed, index=\(currentItemIndex), url=\(urlString)")
                }
                return .dismiss
            }
            CTContentLog.error("No items, forwarding action to host app")
            return .dismissAndForwardAction
        }
        return .doNotDismiss
    }

    @objc func showNext() {
        moveSlider(direction: 1)
    }
    
    func showPrevious() {
        moveSlider(direction: -1)
    }
    
    func moveSlider(direction: Int) {
        guard let _ = getParentViewController() else {
            CTContentLog.info("Controller detached, stopping autoplay timer")
            timer?.invalidate()
            timer = nil
            return
        }
        guard !itemViews.isEmpty else {
            CTContentLog.error("No items to page through")
            return
        }
        currentItemView.removeFromSuperview()

        currentItemIndex = currentItemIndex + direction
        if currentItemIndex >= itemViews.count {
            currentItemIndex = 0
        } else if currentItemIndex < 0 {
            currentItemIndex = itemViews.count - 1
        }
        CTContentLog.info("Paging to index=\(currentItemIndex)/\(itemViews.count), direction=\(direction)")

        currentItemView = itemViews[currentItemIndex]
        contentView.addSubview(currentItemView)
        currentItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            currentItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            currentItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currentItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        pageControl.currentPage = currentItemIndex
        if templateType == TemplateConstants.kTemplateManualCarousel {
            contentView.bringSubviewToFront(nextButton)
            contentView.bringSubviewToFront(previousButton)
        }
    }
    
    func startAutoPlay() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(showNext), userInfo: nil, repeats: true)
        }
    }
    
    @objc public override func getDeeplinkUrl() -> String! {
        return currentActionUrl
    }

    private func resolveDeeplink(_ deeplink: String?, fallback: String) -> String {
        guard let deeplink = deeplink, !deeplink.isEmpty else { return fallback }
        return deeplink
    }
}
