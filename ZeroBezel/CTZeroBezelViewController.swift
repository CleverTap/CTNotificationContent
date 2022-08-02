//
//  CTZeroBezelViewController.swift
//  CleverTap-iOS-SDK
//
//  Created by Aishwarya Nanna on 02/08/22.
//

import UIKit

struct ZeroBezelProperties: Decodable {
    let pt_title: String?
    let pt_msg: String?
    let pt_msg_summary: String?
    let pt_subtitle: String?
    let pt_big_img: String?
//    let pt_small_view: String?
    let pt_dl1: String?
    let pt_title_clr: String?
    let pt_msg_clr: String?
    let pt_small_icon_clr: String?
//    let pt_ico:String?
}

class CTZeroBezelViewController: BaseCTNotificationContentViewController,UIGestureRecognizerDelegate {

    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubCaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: ZeroBezelProperties? = nil
    var templateBigImage:String = ""
    var templateDl1:String = ""
    var heightConstant:CGFloat = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addGestureReconizerToImageView()
        createView()
    }

    func viewWithoutImage(){
        NSLayoutConstraint.activate([
            bigImageView.heightAnchor.constraint(equalToConstant: 0)
        ])
        heightConstant = 161
    }

    func addGestureReconizerToImageView(){
        
        let tapGRBigImage = UITapGestureRecognizer(target: self, action: #selector(self.openDefaultDeepLink))
        tapGRBigImage.delegate = self
        bigImageView.isUserInteractionEnabled = true
        bigImageView.addGestureRecognizer(tapGRBigImage)
        
        let tapGRTitle = UITapGestureRecognizer(target: self, action: #selector(self.openDefaultDeepLink))
        tapGRTitle.delegate = self
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGRTitle)
        
        let tapGRSubTitle = UITapGestureRecognizer(target: self, action: #selector(self.openDefaultDeepLink))
        tapGRSubTitle.delegate = self
        subTitleLabel.isUserInteractionEnabled = true
        subTitleLabel.addGestureRecognizer(tapGRSubTitle)
        
    }
    
    @objc func openDefaultDeepLink(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: deeplinkURL){
            getParentViewController().open(url)
        }
    }
    
    func createView() {
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(ZeroBezelProperties.self, from: configData)
            } catch let error {
                print("Failed to load: \(error.localizedDescription)")
                jsonContent = nil
            }
        }
        guard let jsonContent = jsonContent else {
            return
        }
        
        if let title = jsonContent.pt_title, !title.isEmpty{
            templateCaption = title
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty{
            templateSubCaption = msg
        }
        if let deeplink = jsonContent.pt_dl1, !deeplink.isEmpty{
            deeplinkURL = deeplink
        }
    
        if let bigImage = jsonContent.pt_big_img, !bigImage.isEmpty{
            templateBigImage = bigImage
        }
        
        self.titleLabel.text = templateCaption
        self.subTitleLabel.text = templateSubCaption
    
        if let bigImg = jsonContent.pt_big_img{
            CTUtiltiy.checkImageUrlValid(imageUrl: bigImg) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        self?.bigImageView.image = imageData
                    }else{
                        //handle when image url is invalid
                        self?.templateBigImage = ""
                        self?.updateUI()
                    }
                }
            }
        }else{
            //handle when image is not provided
            templateBigImage = ""
        }
        
        updateUI()
        
        if let titleColor = jsonContent.pt_title_clr {
            self.titleLabel.textColor = UIColor(hex: titleColor)
        }
        if let msgColor = jsonContent.pt_msg_clr {
            self.subTitleLabel.textColor = UIColor(hex: msgColor)
        }
        
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth - heightConstant
//        + getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) - heightConstant
//        + getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
//        view.bringSubviewToFront(titleLabel)
    }
    
    func updateUI(){
        if templateBigImage == ""{
            viewWithoutImage()
        }
    }
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }

    @objc public override func handleAction(_ action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if !deeplinkURL.isEmpty {
                if let url = URL(string: deeplinkURL) {
                    getParentViewController().open(url)
                }
            }
            return .dismiss
        }
        return .doNotDismiss
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
        super.init(nibName: "CTZeroBezelViewController", bundle: Bundle(for: CTZeroBezelViewController.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
