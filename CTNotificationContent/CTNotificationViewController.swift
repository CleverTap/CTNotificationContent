import UIKit
import UserNotifications
import UserNotificationsUI

open class CTNotificationViewController: UIViewController, UNNotificationContentExtension {
    
    open var contentType: CTNotificationContentType = .basicTemplate
    var label:UILabel!
    var orientation: String = ""
    var data: String = ""

    open override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 300)
        super.viewDidLoad()
    }
    
    private func template_view(template:String) {
        switch contentType {
        case .contentSlider:
            let secondVC = CarouselTemplate()
            secondVC.myData = self.data
            addChild(secondVC)
            self.view.addSubview(secondVC.view)
            secondVC.view.frame = self.view.bounds
        case .basicTemplate:
            let secondVC = CTCaptionImageView()
            secondVC.myData = self.data
            addChild(secondVC)
            self.view.addSubview(secondVC.view)
            secondVC.view.frame = self.view.bounds
        case .timerTemplate:
            let secondVC = CTCaptionImageView()
            secondVC.myData = self.data
            addChild(secondVC)
            self.view.addSubview(secondVC.view)
            secondVC.view.frame = self.view.bounds
        }
    }
    public func didReceive(_ notification: UNNotification) {
        let content = notification.request.content.userInfo as? [String:Any]
        self.data = content?["ct_data"] as! String
        template_view(template: content?["ct_template"] as! String)
    }
    
    open func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
        print("userDidPerformAction \(action) with props \(String(describing: properties))")
    }
    
    open func userDidReceive(_ response: UNNotificationResponse?) {
        print("Push Notification Payload \(String(describing: response?.notification.request.content.userInfo))")
    }
    
    public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        // Handle various actions.
        if response.actionIdentifier == "action_2" {
            let myfunc = Carousel()
            myfunc.selectNext()
        } else if response.actionIdentifier == "action2" {
            
        }

        // Dont dismiss extension to allow further interaction.
        completion(.doNotDismiss)
    }
}
