import UIKit
import UserNotifications
import UserNotificationsUI

fileprivate enum Constants {
    static let kContentSlider: String = "ct_ContentSlider"
    static let kTemplateId: String = "pt_id"
    static let kTemplateCarousel: String = "pt_carousel"
    static let kDefaultString: String = ""
}

fileprivate enum CTNotificationContentType: Int {
    case contentSlider = 0
    // Add new templates type here
}

open class CTNotificationViewController : UIViewController, UNNotificationContentExtension {
    private var contentType: CTNotificationContentType = .contentSlider
    private var contentViewController: BaseCTNotificationContentViewController? = nil
    
    // MARK:- Convenience Method
    
    func openUrl(url: URL) {
        self.extensionContext?.open(url, completionHandler: nil)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public func didReceive(_ notification: UNNotification) {
        let content = notification.request.content.userInfo as? [String:Any]
        guard let content = content else {
            return
        }
        
        // TODO: Will add logic for new json data from custom key-value pair here to update contentType.
        
        switch contentType {
        case .contentSlider:
            let contentController = CTContentSliderController()
            contentController.data = content[Constants.kContentSlider] as! String
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        }
        if let contentViewController = contentViewController {
            view.frame = contentViewController.view.frame
            preferredContentSize = contentViewController.preferredContentSize
        }
    }

    // MARK:- Open Access Methods

    open func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
        // no-op here
        // implement in your subclass to get user event type data
    }

    open func userDidReceive(_ response: UNNotificationResponse?) {
        // no-op here
        // implement in your subclass to get user event type data
    }

    public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if let contentViewController = contentViewController {
            var actionResponseOption: UNNotificationContentExtensionResponseOption
            actionResponseOption = contentViewController.handleAction(action: response.actionIdentifier)
            userDidReceive(response)
            completion(actionResponseOption)
        }
    }
}
