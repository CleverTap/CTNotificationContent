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
        
        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
    }
    
    func createView() {
        guard let jsonContent = jsonContent else {
            // Show default alert view and update constraints when json data is not available.
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
        var actionUrl = deeplinkURL
        if let deeplink = jsonContent.pt_dl1, !deeplink.isEmpty {
            actionUrl = deeplink
        }
        deeplinkURL = actionUrl

        if templateType == TemplateConstants.kTemplateBasic {
            var basicImageUrl = ""
            if let url = jsonContent.pt_big_img, !url.isEmpty {
                basicImageUrl = url
            }else if isFromProductDisplay{
                //case for handling image data for product display
                if let url = jsonContent.pt_img1, !url.isEmpty {
                    basicImageUrl = url
                }else if let url = jsonContent.pt_img2, !url.isEmpty {
                    basicImageUrl = url
                }else if let url = jsonContent.pt_img3, !url.isEmpty {
                    basicImageUrl = url
                }
            }

            CTUtiltiy.checkImageUrlValid(imageUrl: basicImageUrl) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        let itemComponents = CaptionedImageViewComponents(caption: self!.templateCaption, subcaption: self!.templateSubcaption, imageUrl: basicImageUrl, actionUrl: actionUrl, bgColor: self!.bgColor, captionColor: self!.captionColor, subcaptionColor: self!.subcaptionColor)
                        let itemView = CTCaptionedImageView(components: itemComponents)
                        self?.itemViews.append(itemView)
                    }
                    self?.setUpConstraints()
                }
            }
        } else if templateType == TemplateConstants.kTemplateAutoCarousel || templateType == TemplateConstants.kTemplateManualCarousel {
            // Add non empty image urls.
            var imageUrls = [String]()
            if let url = jsonContent.pt_img1, !url.isEmpty {
                imageUrls.append(url)
            }
            if let url = jsonContent.pt_img2, !url.isEmpty {
                imageUrls.append(url)
            }
            if let url = jsonContent.pt_img3, !url.isEmpty {
                imageUrls.append(url)
            }
            
            let dispatchGroup = DispatchGroup()
            for (_,url) in imageUrls.enumerated() {
                dispatchGroup.enter()
                CTUtiltiy.checkImageUrlValid(imageUrl: url) { [weak self] (imageData) in
                    DispatchQueue.main.async {
                        if imageData != nil {
                            let itemComponents = CaptionedImageViewComponents(caption: self!.templateCaption, subcaption: self!.templateSubcaption, imageUrl: url, actionUrl: actionUrl, bgColor: self!.bgColor, captionColor: self!.captionColor, subcaptionColor: self!.subcaptionColor)
                            let itemView = CTCaptionedImageView(components: itemComponents)
                            self?.itemViews.append(itemView)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.setUpConstraints()
            }
        }
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
                nextButtonImage = UIImage(named: "ct_next_button", in: Bundle(for: type(of: self)), compatibleWith: nil)!
                nextButton.setImage(nextButtonImage, for: .normal)
                nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
                previousButtonImage = UIImage(named: "ct_previous_button", in: Bundle(for: type(of: self)), compatibleWith: nil)!
                previousButton.setImage(previousButtonImage, for: .normal)
                previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)

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
        let itemComponents = CaptionedImageViewComponents(caption: templateCaption, subcaption: templateSubcaption, imageUrl: "", actionUrl: deeplinkURL, bgColor: bgColor, captionColor: captionColor, subcaptionColor: subcaptionColor)
        let itemView = CTCaptionedImageView(components: itemComponents)
        itemViews.append(itemView)
    }
    
    @objc func nextButtonTapped() {
        showNext()
    }
    
    @objc func previousButtonTapped() {
        showPrevious()
    }

    @objc func openDeeplink() {
        let urlString = itemViews[currentItemIndex].components.actionUrl
        if !urlString.isEmpty {
            if let url = URL(string: urlString) {
                getParentViewController().open(url)
            }
        }
        else {
            if #available(iOS 12.0, *) {
                self.extensionContext?.performNotificationDefaultAction()
            }
        }
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
                let urlString = itemViews[currentItemIndex].components.actionUrl
                if !urlString.isEmpty {
                    if let url = URL(string: urlString) {
                        getParentViewController().open(url)
                    }
                }
                return .dismiss
            }
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
            timer?.invalidate()
            timer = nil
            return
        }
        currentItemView.removeFromSuperview()

        currentItemIndex = currentItemIndex + direction
        if currentItemIndex >= itemViews.count {
            currentItemIndex = 0
        } else if currentItemIndex < 0 {
            currentItemIndex = itemViews.count - 1
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
        let deeplink = itemViews[currentItemIndex].components.actionUrl
        return deeplink
    }
}
