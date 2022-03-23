import UIKit
import UserNotifications
import UserNotificationsUI

class BaseCTNotificationContentViewController: UIViewController {
    func handleAction(action: String) -> UNNotificationContentExtensionResponseOption {
        fatalError("You must override \(#function) in a subclass")
    }
    
    func getParentViewController() -> CTNotificationViewController {
        return parent as! CTNotificationViewController
    }
}
