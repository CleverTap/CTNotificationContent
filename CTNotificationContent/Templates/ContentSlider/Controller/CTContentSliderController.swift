import UIKit
import UserNotificationsUI

fileprivate enum Constants {
    static let kCaption: String = "caption"
    static let kSubcaption: String = "subcaption"
    static let kImageUrl: String = "imageUrl"
    static let kActionUrl: String = "actionUrl"
}

@objc public class CTContentSliderController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var pageControl: UIPageControl = UIPageControl(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    var timer: Timer? = nil
    var items = [[String:String]]()
    var itemViews =  [CTCaptionedImageView]()
    var currentItemIndex: Int = 0
    var autoDismiss: Int = 0
    var showPaging: Int = 0
    var autoPlay: Int = 0
    var orientation: String = ConstantKeys.kOrientationLandscape
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: ContentSliderProperties? = nil
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        
        CTContentLog.info("Content slider controller started")
        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
    }
    
    func createView() {
        guard let jsonContent = jsonContent else {
            CTContentLog.error("Nil payload data, rendering caption only")
            setUpConstraints()
            return
        }

        orientation = jsonContent.orientation
        autoDismiss = jsonContent.autoDismiss
        showPaging = jsonContent.showsPaging
        autoPlay = jsonContent.autoPlay
        CTContentLog.info("Loading \(jsonContent.items.count) items, orientation=\(orientation), autoPlay=\(autoPlay), paging=\(showPaging), autoDismiss=\(autoDismiss)")

        // The downloads finish in any order, so each result is kept under its
        // own position. The arrays are filled in payload order at the end.
        let dispatchGroup = DispatchGroup()
        var orderedItemViews = [Int: CTCaptionedImageView]()
        var orderedItems = [Int: [String: String]]()
        for (index, item) in jsonContent.items.enumerated() {
            dispatchGroup.enter()
            CTUtiltiy.checkImageUrlValid(imageUrl: item.imageUrl) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    defer { dispatchGroup.leave() }
                    guard let self = self else {
                        CTContentLog.error("Controller deallocated before item \(index + 1) arrived")
                        return
                    }
                    guard imageData != nil else {
                        CTContentLog.error("Skipping item \(index + 1), image load failed, url=\(item.imageUrl)")
                        return
                    }

                    var title = item.caption
                    if title.isEmpty {
                        title = self.templateCaption
                    }
                    var subTiltle = item.subcaption
                    if subTiltle.isEmpty {
                        subTiltle = self.templateSubcaption
                    }
                    var action = item.actionUrl
                    if action.isEmpty {
                        action = self.deeplinkURL
                    }

                    let itemComponents = CaptionedImageViewComponents(caption: title, subcaption: subTiltle, imageUrl: item.imageUrl, actionUrl: action, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor, bgColorDark: ConstantKeys.kDefaultColorDark, captionColorDark: ConstantKeys.kHexWhiteColor, subcaptionColorDark: ConstantKeys.kHexDarkGrayColor, imageDescription: item.imgAltText ?? "\(CTAccessibility.kDefaultImageDescription) \(index + 1)")
                    orderedItemViews[index] = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
                    orderedItems[index] = [Constants.kCaption : item.caption, Constants.kSubcaption : item.subcaption, Constants.kImageUrl : item.imageUrl, Constants.kActionUrl : item.actionUrl]
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                CTContentLog.error("Controller deallocated before items arrived")
                return
            }
            let positions = (0..<jsonContent.items.count).filter { orderedItemViews[$0] != nil }
            self.itemViews = positions.compactMap { orderedItemViews[$0] }
            self.items = positions.compactMap { orderedItems[$0] }
            CTContentLog.info("Loaded \(self.itemViews.count)/\(jsonContent.items.count) items")
            self.setUpConstraints()
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
        
        if itemViews.count > 1 {
            if (showPaging != 0) {
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
            }
            if (autoPlay != 0) {
                startAutoPlay()
            } else {
                stopAutoPlay()
            }
        }
    }
    
    func createDefaultAlertView() {
        let itemComponents = CaptionedImageViewComponents(caption: templateCaption, subcaption: templateSubcaption, imageUrl: "", actionUrl: deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor, imageDescription: "")
        let itemView = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
        itemViews.append(itemView)
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

        if orientation == ConstantKeys.kOrientationLandscape  {
            viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + CTUtiltiy.getCaptionHeight()
        }

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)

    }
    
    
    /// Deeplink of the item on screen. Empty when there is no item.
    private var currentActionUrl: String {
        guard currentItemIndex >= 0, currentItemIndex < itemViews.count else {
            CTContentLog.error("No item at index \(currentItemIndex)/\(itemViews.count), no deeplink available")
            return ""
        }
        return itemViews[currentItemIndex].components.actionUrl
    }

    /// Payload of the item on screen, reported back to the host app.
    /// itemViews holds one more entry than items when the fallback caption view
    /// is shown, so the index is checked against items on its own.
    private var currentItemProperties: [String: String] {
        guard currentItemIndex >= 0, currentItemIndex < items.count else {
            return [:]
        }
        return items[currentItemIndex]
    }

    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
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
                let urlString = currentActionUrl
                getParentViewController()?.userDidPerformAction(ConstantKeys.kOpenedContentUrlAction, withProperties: currentItemProperties)
                if urlString.isEmpty {
                    CTContentLog.info("No deeplink for current item")
                } else if let url = URL(string: urlString) {
                    CTContentLog.info("Opening deeplink, url=\(urlString)")
                    getParentViewController()?.open(url)
                } else {
                    CTContentLog.error("Deeplink parse failed, url=\(urlString)")
                }
                return (autoDismiss == 1) ? .dismiss : .doNotDismiss
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
            stopAutoPlay()
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

        getParentViewController()?.userDidPerformAction(ConstantKeys.kViewContentItemAction, withProperties: currentItemProperties)
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
    
    @objc public override func getDeeplinkUrl() -> String! {
        return currentActionUrl
    }
}
