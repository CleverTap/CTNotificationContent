//
//  ViewController.swift
//  CTNotificationServiceExampleSPM
//
//  Created by Aditi Agrawal on 18/09/21.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func sendBasicTemplate(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("BasicTemplate_NotificationSent")
    }
    
    @IBAction func sendCarouselTemplate(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("CarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendTimerTemplate(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("TimerTemplate_NotificationSent")
    }
    
    @IBAction func sendCustomBasic(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("CutomBasicTemplate_NotificationSent")
    }
    
    @IBAction func sendCustomAutoCarousel(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("CustomAutoCarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendCustomManualCarousel(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("CustomManualCarouselTemplate_NotificationSent")
    }
    
    @IBAction func sendVideoMedia(_ sender: Any) {
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

