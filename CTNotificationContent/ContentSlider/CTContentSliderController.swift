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
    static let kOrientationLandscape: String = "landscape"
    static let kAction1: String = "action_1" // Maps to Show Previous
    static let kAction2: String = "action_2" // Maps to Show Next
    static let kAction3: String = "action_3" // Maps to open the attached deeplink
    static let kOpenedContentUrlAction: String = "CTOpenedContentUrl"
    static let kViewContentItemAction: String = "CTViewedContentItem"
    static let kAutoPlayInterval: Int = 3
    static let kLandscapeMultiplier: CGFloat = 0.5625 // 16:9 in landscape
    static let kPageControlViewHeight: CGFloat = 20.0
}

class CTContentSliderController: BaseCTNotificationContentViewController {
    private var captionHeight: CGFloat = 0.0
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
        captionHeight = CTCaptionedImageView.getCaptionHeight()
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
        var viewHeight = viewWidth + captionHeight

        if jsonContent.orientation == Constants.kOrientationLandscape  {
            viewHeight = (viewWidth * (Constants.kLandscapeMultiplier)) + captionHeight
        }

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)

        autoDismiss = jsonContent.autoDismiss
        for item in jsonContent.items {
            let itemView = CTCaptionedImageView(caption: item.caption, subcaption: item.subcaption, imageUrl: item.imageUrl, actionUrl: item.actionUrl)
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
                pageControl.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(captionHeight + Constants.kPageControlViewHeight)),
                pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                pageControl.heightAnchor.constraint(equalToConstant: Constants.kPageControlViewHeight)
            ])
        }
        if (jsonContent.autoPlay != 0) {
            startAutoPlay()
        } else {
            stopAutoPlay()
        }
    }
    
    
    override func handleAction(action: String) -> UNNotificationContentExtensionResponseOption {
        if action == Constants.kAction1 {
            // Maps to show previous
            stopAutoPlay()
            showPrevious()
        } else if action == Constants.kAction2 {
            // Maps to show next
            stopAutoPlay()
            showNext()
        } else if action == Constants.kAction3 {
            // Maps to run the relevant deeplink
            if itemViews.count > 0 {
                let urlString = itemViews[currentItemIndex].actionUrl
                getParentViewController().userDidPerformAction(Constants.kOpenedContentUrlAction, withProperties: items[currentItemIndex])
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

        getParentViewController().userDidPerformAction(Constants.kViewContentItemAction, withProperties: items[currentItemIndex])
    }
    
    func startAutoPlay() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.kAutoPlayInterval), target: self, selector: #selector(showNext), userInfo: nil, repeats: true)
        }
    }
    
    func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }
    
}
