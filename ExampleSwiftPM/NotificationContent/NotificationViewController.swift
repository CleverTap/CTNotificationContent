import CTNotificationContent

class NotificationViewController: CTNotificationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // optional: implement to get user event data
    override func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
        print("userDidPerformAction \(action) with props \(String(describing: properties))")
    }
    
}
