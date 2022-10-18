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
    
    @IBAction func sendCutomBasicTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("CutomBasicTemplate_NotificationSent")
    }
    
    @IBAction func sendCustomAutoCarouselTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("CustomAutoCarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendCustomManualCarouselTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("CustomManualCarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendVideoMediaTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("VideoMediaTemplate_NotificationSent")
    }
    
    @IBAction func sendZeroBezelTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("ZeroBezelTemplate_NotificationSent")
    }
   
    @IBAction func sendProductDisplay_LinearTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("ProductDisplay_LinearTemplate_NotificationSent")
    }
    
    @IBAction func sendProductDisplay_VerticalTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("ProductDisplay_VerticalTemplate_NotificationSent")
    }
    
    @IBAction func sendRatingTemplate(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent("RatingTemplate_NotificationSent")
    }
    
}

