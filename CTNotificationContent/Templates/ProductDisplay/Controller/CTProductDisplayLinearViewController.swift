//
//  PDLinearView.swift
//  PDT
//
//  Created by Aishwarya Nanna on 04/03/22.
//

import UIKit
import UserNotificationsUI

@objc public class CTProductDisplayLinearViewController: BaseCTNotificationContentViewController,UIGestureRecognizerDelegate{

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: ProductDisplayProperties? = nil
    var deeplink: String = ""

    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyBtnOutlet: UIButton!
    @IBOutlet weak var smallImageBtn1: UIImageView!
    @IBOutlet weak var smallImageBtn2: UIImageView!
    @IBOutlet weak var smallImageBtn3: UIImageView!
    
    // Light mode colors
    var bgColor: String = ConstantKeys.kDefaultColor
    var titleColor: String = ConstantKeys.kHexBlackColor
    var productDisplayActionColor: String = ConstantKeys.kHexLightGrayColor
    var productDisplayActionTextColor: String = ConstantKeys.kHexBlackColor
    
    // Dark mode colors
    var bgColorDark: String = ConstantKeys.kHexBlackColor
    var titleColorDark: String = ConstantKeys.kDefaultColor
    var productDisplayActionColorDark: String = ConstantKeys.kHexBlackColor
    var productDisplayActionTextColorDark: String = ConstantKeys.kDefaultColor
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.addGestureReconizerToImageView()
        createView()

        // Register for trait changes on iOS 17+
        if #available(iOSApplicationExtension 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                    self.updateInterfaceColors()
                }
            }
        }
    }
    
    func addGestureReconizerToImageView(){
        let tapGR1 = UITapGestureRecognizer(target: self, action: #selector(self.smallImageAction))
        tapGR1.delegate = self
        smallImageBtn1.tag = 1
        smallImageBtn1.addGestureRecognizer(tapGR1)
        
        let tapGR2 = UITapGestureRecognizer(target: self, action: #selector(self.smallImageAction))
        tapGR2.delegate = self
        smallImageBtn2.tag = 2
        smallImageBtn2.addGestureRecognizer(tapGR2)

        let tapGR3 = UITapGestureRecognizer(target: self, action: #selector(self.smallImageAction))
        tapGR3.delegate = self
        smallImageBtn3.tag = 3
        smallImageBtn3.addGestureRecognizer(tapGR3)
    }

    @IBAction func buyAction(_ sender: UIButton) {
        if let url = URL(string: deeplink){
            getParentViewController().open(url)
        }
    }
    
    @objc func smallImageAction(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag{
        case 1:
            self.bigImageView.image = smallImageBtn1.image
            self.priceLabel.text = jsonContent?.pt_bt1
            self.deeplink = jsonContent?.pt_dl1 ?? ""
            break
        case 2:
            self.bigImageView.image = smallImageBtn2.image
            self.priceLabel.text = jsonContent?.pt_bt2
            self.deeplink = jsonContent?.pt_dl2 ?? ""
            break
        case 3:
            self.bigImageView.image = smallImageBtn3.image
            self.priceLabel.text = jsonContent?.pt_bt3
            self.deeplink = jsonContent?.pt_dl3 ?? ""
            break
        default:
            break
        }
    }

    func createView() {
        guard let jsonContent = jsonContent else {
            return
        }
        let viewWidth = view.frame.size.width
        let viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + buyBtnOutlet.frame.height + smallImageBtn1.frame.height + 50 //imageview + buynowbutton + smallimageview + padding

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
        self.deeplink = jsonContent.pt_dl1
        
        CTUtiltiy.checkImageUrlValid(imageUrl: jsonContent.pt_img1) { [weak self] (imageData) in
            DispatchQueue.main.async {
                if imageData != nil {
                    self?.smallImageBtn1.image = imageData
                    self?.bigImageView.image = imageData
                }
            }
        }
        CTUtiltiy.checkImageUrlValid(imageUrl: jsonContent.pt_img2) { [weak self] (imageData) in
            DispatchQueue.main.async {
                if imageData != nil {
                    self?.smallImageBtn2.image = imageData
                }
            }
        }
        if let img3 = jsonContent.pt_img3, !img3.isEmpty ,(jsonContent.pt_bt3 != nil && jsonContent.pt_st3 != nil && jsonContent.pt_dl3 != nil){
            CTUtiltiy.checkImageUrlValid(imageUrl: img3) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        self?.smallImageBtn3.image = imageData
                    }
                }
            }
        }else{
            self.smallImageBtn3.isUserInteractionEnabled=false
        }
        
        self.priceLabel.text = jsonContent.pt_bt1
        self.buyBtnOutlet.setTitle(jsonContent.pt_product_display_action, for: .normal)
        
        // Set light mode colors
        if let bg = jsonContent.pt_bg, !bg.isEmpty {
            bgColor = bg
        }
        if let titleClr = jsonContent.pt_title_clr, !titleClr.isEmpty {
            titleColor = titleClr
        }
        if let actionColor = jsonContent.pt_product_display_action_clr, !actionColor.isEmpty {
            productDisplayActionColor = actionColor
        }
        if let actionTextColor = jsonContent.pt_product_display_action_text_clr, !actionTextColor.isEmpty {
            productDisplayActionTextColor = actionTextColor
        }
        
        // Handle dark mode colors
        if let bgDark = jsonContent.pt_bg_dark, !bgDark.isEmpty {
            bgColorDark = bgDark
        }
        if let titleClrDark = jsonContent.pt_title_clr_dark, !titleClrDark.isEmpty {
            titleColorDark = titleClrDark
        }
        if let actionColorDark = jsonContent.pt_product_display_action_clr_dark, !actionColorDark.isEmpty {
            productDisplayActionColorDark = actionColorDark
        }
        if let actionTextColorDark = jsonContent.pt_product_display_action_text_clr_dark, !actionTextColorDark.isEmpty {
            productDisplayActionTextColorDark = actionTextColorDark
        }
        
        updateInterfaceColors()
    }
    
    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handle trait changes, for iOS 17+ it is handled by registerForTraitChanges.
        if #available(iOSApplicationExtension 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateInterfaceColors()
            }
        }
    }
    
    func updateInterfaceColors() {
        // Check if device is in dark mode (iOS 12+)
        let isDarkMode: Bool
        
        if #available(iOSApplicationExtension 12.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        } else {
            // For iOS versions before 12.0, using light mode colors since dark mode wasn't officially supported
            isDarkMode = false
        }
        
        view.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
        priceLabel.textColor = UIColor(hex: isDarkMode ? titleColorDark : titleColor)
        buyBtnOutlet.backgroundColor = UIColor(hex: isDarkMode ? productDisplayActionColorDark : productDisplayActionColor)
        buyBtnOutlet.setTitleColor(UIColor(hex: isDarkMode ? productDisplayActionTextColorDark : productDisplayActionTextColor), for: .normal)
    }
    
    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if let url = URL(string: deeplink){
                getParentViewController().open(url)
            }
            return .dismiss
        }
        return .doNotDismiss
    }
    
    @objc public override func getDeeplinkUrl() -> String! {
        return deeplink
    }
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    public init() {
        super.init(nibName: "CTProductDisplayLinearViewController", bundle: Bundle(for: CTProductDisplayLinearViewController.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
