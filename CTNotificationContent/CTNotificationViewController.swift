import UIKit
import UserNotifications
import UserNotificationsUI

fileprivate enum CTNotificationContentType: Int {
    // Dashboard
    case contentSlider = 0
    case singleMedia = 1
    // Custom key-value pairs
    case basicTemplate = 2
    case autoCarousel = 3
    case manualCarousel = 4
    case timerTemplate = 5
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

        if content[TemplateConstants.kContentSlider] as? String != nil {
            contentType = .contentSlider
        } else {
            if content[TemplateConstants.kTemplateId] as? String != nil {
                if content[TemplateConstants.kTemplateId] as? String == TemplateConstants.kTemplateBasic {
                    contentType = .basicTemplate
                } else if content[TemplateConstants.kTemplateId] as? String == TemplateConstants.kTemplateAutoCarousel {
                    contentType = .autoCarousel
                } else if content[TemplateConstants.kTemplateId] as? String == TemplateConstants.kTemplateManualCarousel {
                    contentType = .manualCarousel
                } else if content[TemplateConstants.kTemplateId] as? String == TemplateConstants.kTemplateTimer {
                    contentType = .timerTemplate
                }
            } else if content[ConstantKeys.kSingleMediaType] as? String != nil && content[ConstantKeys.kSingleMediaURL] as? String != nil {
                contentType = .singleMedia
            }
        }
        
        switch contentType {
        case .contentSlider:
            let contentController = CTContentSliderController()
            contentController.data = content[TemplateConstants.kContentSlider] as! String
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        case .singleMedia:
            let contentController = CTSingleMediaController()
            contentController.caption = notification.request.content.title
            contentController.subCaption = notification.request.content.body
            contentController.mediaType = content[ConstantKeys.kSingleMediaType] as! String
            contentController.mediaURL = content[ConstantKeys.kSingleMediaURL] as! String
            if content[ConstantKeys.kDeeplinkURL] as? String != nil {
                contentController.deeplinkURL = content[ConstantKeys.kDeeplinkURL] as! String
            }
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        case .basicTemplate:
            let contentController = CTCarouselController()
            contentController.data = content[ConstantKeys.kJSON] as! String
            contentController.templateType = TemplateConstants.kTemplateBasic
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        case .autoCarousel:
            let contentController = CTCarouselController()
            contentController.data = content[ConstantKeys.kJSON] as! String
            contentController.templateType = TemplateConstants.kTemplateAutoCarousel
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        case .manualCarousel:
            let contentController = CTCarouselController()
            contentController.data = content[ConstantKeys.kJSON] as! String
            contentController.templateType = TemplateConstants.kTemplateManualCarousel
            addChild(contentController)
            self.view.addSubview(contentController.view)
            contentController.view.frame = self.view.bounds
            contentViewController = contentController
        case .timerTemplate:
            let contentController = CTTimerTemplateController()
            contentController.data = content[ConstantKeys.kJSON] as! String
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
