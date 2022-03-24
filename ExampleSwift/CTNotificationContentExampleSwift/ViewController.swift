import UIKit
import CleverTapSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendBasicTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("BasicTemplate_NotificationSent")
    }
    
    @IBAction func sendCarouselTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("CarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendTimerTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("TimerTemplate_NotificationSent")
    }
    
    
}

