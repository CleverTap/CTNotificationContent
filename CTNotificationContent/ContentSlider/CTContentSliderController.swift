import UIKit
import UserNotificationsUI

struct ContentSliderProperties: Decodable {
    let orientation: String
    let showsPaging: Int
    let autoPlay: Int
    let autoDismiss: Int
    let items: [ItemContent]
    let type: String
}

struct ItemContent: Decodable {
    let caption: String
    let subcaption: String
    let imageUrl: String
    let actionUrl: String
}

fileprivate enum Constants {
    static let kCaption: String = "caption"
    static let kSubcaption: String = "subcaption"
    static let kImageUrl: String = "imageUrl"
    static let kActionUrl: String = "actionUrl"
}

class CTContentSliderController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var pageControl: UIPageControl = UIPageControl(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    var timer: Timer? = nil
    var items = [[String:String]]()
    var itemViews =  [CTCaptionedImageView]()
    var currentItemIndex: Int = 0
    var autoDismiss: Int = 0
    var data: String = ""
    var jsonContent: ContentSliderProperties? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        createView()
    }
    
    func createView() {
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(ContentSliderProperties.self, from: configData)
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

        if jsonContent.orientation == ConstantKeys.kOrientationLandscape  {
            viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight()
        }

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)

        autoDismiss = jsonContent.autoDismiss
        for item in jsonContent.items {
            let itemComponents = CaptionedImageViewComponents(caption: item.caption, subcaption: item.subcaption, imageUrl: item.imageUrl, actionUrl: item.actionUrl, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor)
            let itemView = CTCaptionedImageView(components: itemComponents)
            itemViews.append(itemView)
            
            let keyItem = [Constants.kCaption : item.caption, Constants.kSubcaption : item.subcaption, Constants.kImageUrl : item.imageUrl, Constants.kActionUrl : item.actionUrl]
            items.append(keyItem)
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
        if (jsonContent.showsPaging != 0) {
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
        }
        if (jsonContent.autoPlay != 0) {
            startAutoPlay()
        } else {
            stopAutoPlay()
        }
    }
    
    
    override func handleAction(action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction1 {
            // Maps to show previous
            stopAutoPlay()
            showPrevious()
        } else if action == ConstantKeys.kAction2 {
            // Maps to show next
            stopAutoPlay()
            showNext()
        } else if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if itemViews.count > 0 {
                let urlString = itemViews[currentItemIndex].components.actionUrl
                getParentViewController().userDidPerformAction(ConstantKeys.kOpenedContentUrlAction, withProperties: items[currentItemIndex])
                let url = URL(string: urlString)!
                getParentViewController().openUrl(url: url)
                return (autoDismiss == 1) ? .dismiss : .doNotDismiss
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

        getParentViewController().userDidPerformAction(ConstantKeys.kViewContentItemAction, withProperties: items[currentItemIndex])
    }
    
    func startAutoPlay() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(showNext), userInfo: nil, repeats: true)
        }
    }
    
    func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
}
