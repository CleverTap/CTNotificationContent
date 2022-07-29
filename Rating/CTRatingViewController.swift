//
//  CTRatingViewController.swift
//  CTNotificationContent
//
//  Created by Aishwarya Nanna on 27/07/22.
//

import UIKit

struct RatingProperties: Decodable {
    let pt_title: String?
    let pt_msg: String?
    let pt_msg_summary: String?
    let pt_subtitle: String?
    let pt_default_dl: String?
    let pt_dl1: String?
    let pt_dl2: String?
    let pt_dl3: String?
    let pt_dl4: String?
    let pt_dl5: String?
    let pt_big_img: String?
    let pt_bg: String?
    let pt_title_clr: String?
    let pt_msg_clr: String?
    let pt_small_icon_clr: String?
}

class CTRatingViewController: BaseCTNotificationContentViewController, UIGestureRecognizerDelegate {
    
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubCaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: RatingProperties? = nil
    var templateBigImage:String = ""
    var templateDl1:String = ""
    var heightConstant:CGFloat = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet weak var oneStarImageView: UIImageView!
    @IBOutlet weak var twoStarImageView: UIImageView!
    @IBOutlet weak var threeStarImageView: UIImageView!
    @IBOutlet weak var fourStarImageView: UIImageView!
    @IBOutlet weak var fiveStarImageView: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.addGestureReconizerToImageView()
        createView()
        // Do any additional setup after loading the view.
    }
    
    func viewWithoutImage(){
        NSLayoutConstraint.activate([
            bigImageView.heightAnchor.constraint(equalToConstant: 0)
        ])
        heightConstant = 161
    }
    func viewWithoutRating(){
        NSLayoutConstraint.activate([
            starStackView.heightAnchor.constraint(equalToConstant: 0)
        ])
        heightConstant = 50
    }
    func viewWithoutImageandRating(){
        NSLayoutConstraint.activate([
            bigImageView.heightAnchor.constraint(equalToConstant: 0)
        ])
        NSLayoutConstraint.activate([
            starStackView.heightAnchor.constraint(equalToConstant: 0)
        ])
        heightConstant = 231
    }
    func addGestureReconizerToImageView(){
        let tapGR1 = UITapGestureRecognizer(target: self, action: #selector(self.selectOneStar))
        tapGR1.delegate = self
        oneStarImageView.isUserInteractionEnabled = true
        oneStarImageView.addGestureRecognizer(tapGR1)
        
        let tapGR2 = UITapGestureRecognizer(target: self, action: #selector(self.selectTwoStar))
        tapGR2.delegate = self
        twoStarImageView.isUserInteractionEnabled = true
        twoStarImageView.addGestureRecognizer(tapGR2)

        let tapGR3 = UITapGestureRecognizer(target: self, action: #selector(self.selectThreeStar))
        tapGR3.delegate = self
        threeStarImageView.isUserInteractionEnabled = true
        threeStarImageView.addGestureRecognizer(tapGR3)
        
        let tapGR4 = UITapGestureRecognizer(target: self, action: #selector(self.selectFourStar))
        tapGR3.delegate = self
        fourStarImageView.isUserInteractionEnabled = true
        fourStarImageView.addGestureRecognizer(tapGR4)
        
        let tapGR5 = UITapGestureRecognizer(target: self, action: #selector(self.selectFiveStar))
        tapGR5.delegate = self
        fiveStarImageView.isUserInteractionEnabled = true
        fiveStarImageView.addGestureRecognizer(tapGR5)
        
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
    
    @objc func selectOneStar(_ sender: UITapGestureRecognizer) {
        oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        if let url = jsonContent?.pt_dl1{
            if let url = URL(string: url){
                getParentViewController().open(url)
            }
        }
        
    }
    @objc func selectTwoStar(_ sender: UITapGestureRecognizer) {
        oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        if let url = jsonContent?.pt_dl2{
            if let url = URL(string: url){
                getParentViewController().open(url)
            }
        }else{
            if let url = jsonContent?.pt_dl1{
                if let url = URL(string: url){
                    getParentViewController().open(url)
                }
            }
        }
    }
    @objc func selectThreeStar(_ sender: UITapGestureRecognizer) {
        oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        if let url = jsonContent?.pt_dl3{
            if let url = URL(string: url){
                getParentViewController().open(url)
            }
        }else{
            if let url = jsonContent?.pt_dl1{
                if let url = URL(string: url){
                    getParentViewController().open(url)
                }
            }
        }
    }
    @objc func selectFourStar(_ sender: UITapGestureRecognizer) {
        oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        if let url = jsonContent?.pt_dl2{
            if let url = URL(string: url){
                getParentViewController().open(url)
            }
        }else{
            if let url = jsonContent?.pt_dl1{
                if let url = URL(string: url){
                    getParentViewController().open(url)
                }
            }
        }
    }
    @objc func selectFiveStar(_ sender: UITapGestureRecognizer) {
        oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        if let url = jsonContent?.pt_dl2{
            if let url = URL(string: url){
                getParentViewController().open(url)
            }
        }else{
            if let url = jsonContent?.pt_dl1{
                if let url = URL(string: url){
                    getParentViewController().open(url)
                }
            }
        }
    }
    
    @objc func openDefaultDeepLink(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: deeplinkURL){
            getParentViewController().open(url)
        }
    }
    
    func createView() {
        if let configData = data.data(using: .utf8) {
            do {
                jsonContent = try JSONDecoder().decode(RatingProperties.self, from: configData)
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
        if let deeplink = jsonContent.pt_default_dl, !deeplink.isEmpty{
            deeplinkURL = deeplink
        }
        if let dl1 = jsonContent.pt_dl1, !dl1.isEmpty{
            templateDl1 = dl1
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
        
        if let bgColor = jsonContent.pt_bg,!bgColor.isEmpty{
            view.backgroundColor = UIColor(hex: bgColor)
        }
        if let titleColor = jsonContent.pt_title_clr {
            self.titleLabel.textColor = UIColor(hex: titleColor)
        }
        if let msgColor = jsonContent.pt_msg_clr {
            self.subTitleLabel.textColor = UIColor(hex: msgColor)
        }
        
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + getCaptionHeight() - heightConstant
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight() - heightConstant
        

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
        
    }
    
    func updateUI(){
        if templateBigImage == "" && templateDl1 == ""{
            viewWithoutImageandRating()
        }else if templateBigImage == ""{
            viewWithoutImage()
        }else if templateDl1 == ""{
            viewWithoutRating()
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
        super.init(nibName: "CTRatingViewController", bundle: Bundle(for: CTRatingViewController.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
