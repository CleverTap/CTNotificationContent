//
//  CTProductDisplayVerticalViewController.swift
//  PDT
//
//  Created by Aishwarya Nanna on 04/03/22.
//

import UIKit
import UserNotificationsUI

@objc public class CTProductDisplayVerticalViewController: BaseCTNotificationContentViewController, UIGestureRecognizerDelegate {

    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var jsonContent: ProductDisplayProperties? = nil
    var deeplink: String = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyBtnOutlet: UIButton!
    @IBOutlet weak var smallImageBtn1: UIImageView!
    @IBOutlet weak var smallImageBtn2: UIImageView!
    @IBOutlet weak var smallImageBtn3: UIImageView!

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addGestureReconizerToImageView()
        createView()
        // Do any additional setup after loading the view.
    }

    func addGestureReconizerToImageView(){
        let tapGR1 = UITapGestureRecognizer(target: self, action: #selector(self.smallImage1Action))
        tapGR1.delegate = self
        smallImageBtn1.isUserInteractionEnabled = true
        smallImageBtn1.addGestureRecognizer(tapGR1)
        
        let tapGR2 = UITapGestureRecognizer(target: self, action: #selector(self.smallImage2Action))
        tapGR2.delegate = self
        smallImageBtn2.isUserInteractionEnabled = true
        smallImageBtn2.addGestureRecognizer(tapGR2)

        let tapGR3 = UITapGestureRecognizer(target: self, action: #selector(self.smallImage3Action))
        tapGR3.delegate = self
        smallImageBtn3.isUserInteractionEnabled = true
        smallImageBtn3.addGestureRecognizer(tapGR3)
    }
    
    @IBAction func buyAction(_ sender: UIButton) {
        if let url = URL(string: deeplink){
            getParentViewController().open(url)
        }
    }
    
    @objc func smallImage1Action(_ sender: UITapGestureRecognizer) {
        self.bigImageView.image = smallImageBtn1.image
        self.titleLabel.text = jsonContent?.pt_bt1
        self.subTitleLabel.text = jsonContent?.pt_st1
        let priceText = "RS. " + (jsonContent?.pt_price1 ?? "")
        self.priceLabel.text = priceText
        self.deeplink = jsonContent?.pt_dl1 ?? ""
    }
    
    @objc func smallImage2Action(_ sender: UITapGestureRecognizer) {
        self.bigImageView.image = smallImageBtn2.image
        self.titleLabel.text = jsonContent?.pt_bt2
        let priceText = "RS. " + (jsonContent?.pt_price2 ?? "")
        self.priceLabel.text = priceText
        self.subTitleLabel.text = jsonContent?.pt_st2
        self.deeplink = jsonContent?.pt_dl2 ?? ""
    }
    
    @objc func smallImage3Action(_ sender: UITapGestureRecognizer) {
        self.bigImageView.image = smallImageBtn3.image
        self.titleLabel.text = jsonContent?.pt_bt3
        self.subTitleLabel.text = jsonContent?.pt_st3
        let priceText = "RS. " + (jsonContent?.pt_price3 ?? "")
        self.priceLabel.text = priceText
        self.deeplink = jsonContent?.pt_dl3 ?? ""
    }
    
    @objc public func getJson(data: String)->ProductDisplayProperties?{
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(ProductDisplayProperties.self, from: configData)
            } catch let error {
                print("Failed to load: \(error.localizedDescription)")
                jsonContent = nil
            }
        }
        return jsonContent
    }
    
    func createView() {
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(ProductDisplayProperties.self, from: configData)
            } catch let error {
                print("Failed to load: \(error.localizedDescription)")
                jsonContent = nil
            }
        }
        guard let jsonContent = jsonContent else {
            return
        }
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight()

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
        self.deeplink = jsonContent.pt_dl1
        self.titleLabel.text = jsonContent.pt_bt1
        self.subTitleLabel.text = jsonContent.pt_st1

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
        if let img3 = jsonContent.pt_img3, !img3.isEmpty ,(jsonContent.pt_bt3 != nil && jsonContent.pt_st3 != nil && jsonContent.pt_dl3 != nil && jsonContent.pt_price3 != nil){
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
                
        let priceText = "RS. " + (jsonContent.pt_price1)
        self.priceLabel.text = priceText
        self.buyBtnOutlet.setTitle(jsonContent.pt_product_display_action, for: .normal)
        
        view.backgroundColor = UIColor(hex: jsonContent.pt_bg ?? "")
        if let titleColor = jsonContent.pt_title_clr {
            self.titleLabel.textColor = UIColor(hex: titleColor)
        }
        if let msgColor = jsonContent.pt_msg_clr {
            self.subTitleLabel.textColor = UIColor(hex: msgColor)
        }

        buyBtnOutlet.backgroundColor = UIColor(hex: jsonContent.pt_product_display_action_clr ?? "")
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
        super.init(nibName: "CTProductDisplayVerticalViewController", bundle: Bundle(for: CTProductDisplayVerticalViewController.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
