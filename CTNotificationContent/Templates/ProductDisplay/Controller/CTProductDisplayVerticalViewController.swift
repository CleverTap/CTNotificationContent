//
//  CTProductDisplayVerticalViewController.swift
//  PDT
//
//  Created by Aishwarya Nanna on 04/03/22.
//

import UIKit
import UserNotificationsUI

@objc public class CTProductDisplayVerticalViewController: BaseCTNotificationContentViewController, UIGestureRecognizerDelegate {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: ProductDisplayProperties? = nil
    var deeplink: String = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyBtnOutlet: UIButton!
    @IBOutlet weak var smallImageBtn1: UIImageView!
    @IBOutlet weak var smallImageBtn2: UIImageView!
    @IBOutlet weak var smallImageBtn3: UIImageView!
    
    // Color properties with defaults
    var bgColor: String = ConstantKeys.kDefaultColor
    var captionColor: String = ConstantKeys.kHexBlackColor
    var subcaptionColor: String = ConstantKeys.kHexLightGrayColor
    var productDisplayActionColor: String = ConstantKeys.kHexWhiteColor
    // Dark mode colors
    var bgColorDark: String = ConstantKeys.kDefaultColorDark
    var captionColorDark: String = ConstantKeys.kHexWhiteColor
    var subcaptionColorDark: String = ConstantKeys.kHexDarkGrayColor
    var productDisplayActionColorDark: String = ConstantKeys.kHexBlackColor
    
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
            self.titleLabel.setHTMLText(jsonContent?.pt_bt1 ?? "")
            self.subTitleLabel.setHTMLText(jsonContent?.pt_st1 ?? "")
            let priceText = "₹ " + (jsonContent?.pt_price1 ?? "")
            self.priceLabel.text = priceText
            self.titleLabel.accessibilityIdentifier = "CTNotificationTitle1"
            self.subTitleLabel.accessibilityIdentifier = "CTNotificationBody1"
            self.priceLabel.accessibilityIdentifier = "CTNotificationPrice1"
            break
        case 2:
            self.bigImageView.image = smallImageBtn2.image
            self.deeplink = jsonContent?.pt_dl2 ?? ""
            self.titleLabel.setHTMLText(jsonContent?.pt_bt2 ?? "")
            self.subTitleLabel.setHTMLText(jsonContent?.pt_st2 ?? "")
            let priceText = "₹ " + (jsonContent?.pt_price2 ?? "")
            self.priceLabel.text = priceText
            self.titleLabel.accessibilityIdentifier = "CTNotificationTitle2"
            self.subTitleLabel.accessibilityIdentifier = "CTNotificationBody2"
            self.priceLabel.accessibilityIdentifier = "CTNotificationPrice2"
            break
        case 3:
            self.bigImageView.image = smallImageBtn3.image
            self.deeplink = jsonContent?.pt_dl3 ?? ""
            self.titleLabel.setHTMLText(jsonContent?.pt_bt3 ?? "")
            self.subTitleLabel.setHTMLText(jsonContent?.pt_st3 ?? "")
            let priceText = "₹ " + (jsonContent?.pt_price3 ?? "")
            self.priceLabel.text = priceText
            self.titleLabel.accessibilityIdentifier = "CTNotificationTitle3"
            self.subTitleLabel.accessibilityIdentifier = "CTNotificationBody3"
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
        let viewHeight = ((viewWidth/2) * Constraints.kLandscapeMultiplier) + titleLabel.frame.height + subTitleLabel.frame.height + 60

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
        // Set initial deeplink, title, subtitle, and price
        self.deeplink = jsonContent.pt_dl1
        self.titleLabel.setHTMLText(jsonContent.pt_bt1)
        self.subTitleLabel.setHTMLText(jsonContent.pt_st1)
        let priceText = "₹ " + (jsonContent.pt_price1)
        self.priceLabel.text = priceText
        self.titleLabel.accessibilityIdentifier = "CTNotificationTitle1"
        self.subTitleLabel.accessibilityIdentifier = "CTNotificationBody1"
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
           jsonContent.pt_bt3 != nil,
           jsonContent.pt_st3 != nil,
           jsonContent.pt_dl3 != nil,
           jsonContent.pt_price3 != nil {
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
        
        // Handle colors
        if let bg = jsonContent.pt_bg, !bg.isEmpty {
            bgColor = bg
        }
        if let titleColor = jsonContent.pt_title_clr, !titleColor.isEmpty {
            captionColor = titleColor
        }
        if let msgColor = jsonContent.pt_msg_clr, !msgColor.isEmpty {
            subcaptionColor = msgColor
        }
        if let actionColor = jsonContent.pt_product_display_action_clr, !actionColor.isEmpty {
            productDisplayActionColor = actionColor
        }

        // Handle dark mode colors
        if let bgDark = jsonContent.pt_bg_dark, !bgDark.isEmpty {
            bgColorDark = bgDark
        }
        if let titleColorDark = jsonContent.pt_title_clr_dark, !titleColorDark.isEmpty {
            captionColorDark = titleColorDark
        }
        if let msgColorDark = jsonContent.pt_msg_clr_dark, !msgColorDark.isEmpty {
            subcaptionColorDark = msgColorDark
        }
        if let actionColorDark = jsonContent.pt_product_display_action_clr_dark, !actionColorDark.isEmpty {
            productDisplayActionColorDark = actionColorDark
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
        titleLabel.textColor = UIColor(hex: isDarkMode ? captionColorDark : captionColor)
        priceLabel.textColor = UIColor(hex: isDarkMode ? captionColorDark : captionColor)
        subTitleLabel.textColor = UIColor(hex: isDarkMode ? subcaptionColorDark : subcaptionColor)
        buyBtnOutlet.backgroundColor = UIColor(hex: isDarkMode ? productDisplayActionColorDark : productDisplayActionColor)
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
        super.init(nibName: "CTProductDisplayVerticalViewController", bundle: Bundle(for: CTProductDisplayVerticalViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
