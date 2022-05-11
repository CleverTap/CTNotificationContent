import UIKit
import UserNotificationsUI

struct CarouselProperties: Decodable {
    let pt_title: String
    let pt_msg: String
    let pt_msg_summary: String?
    let pt_subtitle: String?    // Not used
    let pt_dl1: String?
    let pt_big_img: String?
    let pt_img1: String?
    let pt_img2: String?
    let pt_img3: String?
    let pt_bg: String
    let pt_ico: String? // Not used
    let pt_title_clr: String?
    let pt_msg_clr: String?
    let pt_small_icon_clr: String?  // Not used
}

class CTCarouselController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var pageControl: UIPageControl = UIPageControl(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    var timer: Timer? = nil
    var itemViews =  [CTCaptionedImageView]()
    var currentItemIndex: Int = 0
    @objc var data: String = ""
    @objc var templateType: String = ""
    var jsonContent: CarouselProperties? = nil
    var nextButtonImage: UIImage = UIImage()
    var previousButtonImage: UIImage = UIImage()
    var nextButton: UIButton = UIButton(frame: .zero)
    var previousButton: UIButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        createView()
    }
    
    func createView() {
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(CarouselProperties.self, from: configData)
            } catch let error {
                print("Failed to load: \(error.localizedDescription)")
                jsonContent = nil
            }
        }
        guard let jsonContent = jsonContent else {
            return
        }
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight()

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
        var subcaption = jsonContent.pt_msg
        var captionColor = ConstantKeys.kHexBlackColor
        var subcaptionColor = ConstantKeys.kHexLightGrayColor
        var actionUrl = ""
        if let msgSummary = jsonContent.pt_msg_summary {
            subcaption = msgSummary
        }
        if let titleColor = jsonContent.pt_title_clr {
            captionColor = titleColor
        }
        if let msgColor = jsonContent.pt_msg_clr {
            subcaptionColor = msgColor
        }
        if let deeplink = jsonContent.pt_dl1 {
            actionUrl = deeplink
        }

        if templateType == TemplateConstants.kTemplateBasic {
            var basicImageUrl = ""
            if let url = jsonContent.pt_big_img {
                basicImageUrl = url
            }
            let itemComponents = CaptionedImageViewComponents(caption: jsonContent.pt_title, subcaption: subcaption, imageUrl: basicImageUrl, actionUrl: actionUrl, bgColor: jsonContent.pt_bg, captionColor: captionColor, subcaptionColor: subcaptionColor)
            let itemView = CTCaptionedImageView(components: itemComponents)
            itemViews.append(itemView)
        } else if templateType == TemplateConstants.kTemplateAutoCarousel || templateType == TemplateConstants.kTemplateManualCarousel {
            // Image 1
            var itemComponents = CaptionedImageViewComponents(caption: jsonContent.pt_title, subcaption: subcaption, imageUrl: jsonContent.pt_img1!, actionUrl: actionUrl, bgColor: jsonContent.pt_bg, captionColor: captionColor, subcaptionColor: subcaptionColor)
            var itemView = CTCaptionedImageView(components: itemComponents)
            itemViews.append(itemView)

            // Image 2
            itemComponents = CaptionedImageViewComponents(caption: jsonContent.pt_title, subcaption: subcaption, imageUrl: jsonContent.pt_img2!, actionUrl: actionUrl, bgColor: jsonContent.pt_bg, captionColor: captionColor, subcaptionColor: subcaptionColor)
            itemView = CTCaptionedImageView(components: itemComponents)
            itemViews.append(itemView)

            // Image 3
            itemComponents = CaptionedImageViewComponents(caption: jsonContent.pt_title, subcaption: subcaption, imageUrl: jsonContent.pt_img3!, actionUrl: actionUrl, bgColor: jsonContent.pt_bg, captionColor: captionColor, subcaptionColor: subcaptionColor)
            itemView = CTCaptionedImageView(components: itemComponents)
            itemViews.append(itemView)
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

        pageControl.numberOfPages = itemViews.count
        pageControl.hidesForSinglePage = true
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(getCaptionHeight() + Constraints.kPageControlViewHeight)),
            pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: Constraints.kPageControlViewHeight)
        ])
        
        if templateType == TemplateConstants.kTemplateAutoCarousel {
            startAutoPlay()
        } else if templateType == TemplateConstants.kTemplateManualCarousel {
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
                
                previousButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100.0),
                previousButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
                previousButton.heightAnchor.constraint(equalToConstant: 40.0)
            ])
            contentView.bringSubviewToFront(nextButton)
            contentView.bringSubviewToFront(previousButton)
        }
    }
    
    @objc func nextButtonTapped() {
        showNext()
    }
    
    @objc func previousButtonTapped() {
        showPrevious()
    }

    override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
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
                    let url = URL(string: urlString)!
                    getParentViewController().open(url)
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
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
}
