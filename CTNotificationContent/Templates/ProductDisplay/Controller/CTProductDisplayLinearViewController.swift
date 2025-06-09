//
//  PDLinearView.swift
//  PDT
//
//  Created by Aishwarya Nanna on 04/03/22.
//

import UIKit
import UserNotificationsUI

@objc public class CTProductDisplayLinearViewController: BaseCTNotificationContentViewController, UIGestureRecognizerDelegate {

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
    }
    
    func addGestureReconizerToImageView() {
        // Enable user interaction for all image views
        smallImageBtn1.isUserInteractionEnabled = true
        smallImageBtn2.isUserInteractionEnabled = true
        smallImageBtn3.isUserInteractionEnabled = true
        
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
        if let url = URL(string: deeplink) {
            getParentViewController().open(url)
        }
    }
    
    @objc func smallImageAction(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 1:
            self.bigImageView.image = smallImageBtn1.image
            self.deeplink = jsonContent?.pt_dl1 ?? ""
            let priceText = "₹ " + (jsonContent?.pt_price1 ?? "")
            self.priceLabel.text = priceText
            self.priceLabel.accessibilityIdentifier = "CTNotificationPrice1"
            break
        case 2:
            self.bigImageView.image = smallImageBtn2.image
            self.deeplink = jsonContent?.pt_dl2 ?? ""
            let priceText = "₹ " + (jsonContent?.pt_price2 ?? "")
            self.priceLabel.text = priceText
            self.priceLabel.accessibilityIdentifier = "CTNotificationPrice2"
            break
        case 3:
            self.bigImageView.image = smallImageBtn3.image
            self.deeplink = jsonContent?.pt_dl3 ?? ""
            let priceText = "₹ " + (jsonContent?.pt_price3 ?? "")
            self.priceLabel.text = priceText
            self.priceLabel.accessibilityIdentifier = "CTNotificationPrice3"
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
        let viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + buyBtnOutlet.frame.height + smallImageBtn1.frame.height + 50

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
        // Set initial deeplink and price
        self.deeplink = jsonContent.pt_dl1
        let priceText = "₹ " + (jsonContent.pt_price1)
        self.priceLabel.text = priceText
        self.priceLabel.accessibilityIdentifier = "CTNotificationPrice1"
        
        // Load images
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
        
        // Check if all required data exists for image 3
        if let img3 = jsonContent.pt_img3, !img3.isEmpty,
           jsonContent.pt_price3 != nil,
           jsonContent.pt_dl3 != nil {
            CTUtiltiy.checkImageUrlValid(imageUrl: img3) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        self?.smallImageBtn3.image = imageData
                    }
                }
            }
        } else {
            self.smallImageBtn3.isUserInteractionEnabled = false
        }
        
        // Set button title
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
        
        if #available(iOSApplicationExtension 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateInterfaceColors()
            }
        }
    }
    
    func updateInterfaceColors() {
        let isDarkMode: Bool
        
        if #available(iOSApplicationExtension 12.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        } else {
            isDarkMode = false
        }
        
        view.backgroundColor = UIColor(hex: isDarkMode ? bgColorDark : bgColor)
        priceLabel.textColor = UIColor(hex: isDarkMode ? titleColorDark : titleColor)
        buyBtnOutlet.backgroundColor = UIColor(hex: isDarkMode ? productDisplayActionColorDark : productDisplayActionColor)
        buyBtnOutlet.setTitleColor(UIColor(hex: isDarkMode ? productDisplayActionTextColorDark : productDisplayActionTextColor), for: .normal)
    }
    
    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            if let url = URL(string: deeplink) {
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
    
    public init() {
        super.init(nibName: "CTProductDisplayLinearViewController", bundle: Bundle(for: CTProductDisplayLinearViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
