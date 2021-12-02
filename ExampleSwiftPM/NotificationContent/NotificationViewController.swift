import CTNotificationContent

class NotificationViewController: CTNotificationViewController {
    
    override func viewDidLoad() {
        self.contentType = .contentSlider // default is .contentSlider, just here for illustration
        super.viewDidLoad()
    }
    
    // optional: implement to get user event data
    override func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
        print("userDidPerformAction \(action) with props \(String(describing: properties))")
    }
    
}
