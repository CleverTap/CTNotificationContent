//
//  CTRatingsViewController.swift
//  CTNotificationContent
//
//  Created by Aishwarya Nanna on 12/10/22.
//

import UIKit

@objc public class CTRatingsViewController: BaseCTNotificationContentViewController, UIGestureRecognizerDelegate {

    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var jsonContent: RatingProperties? = nil
    var templateBigImage:String = ""
    var templateDl1:String = ""
    var imageViewBottomContraint:CGFloat = 0

    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.textAlignment = .left
        subTitleLabel.adjustsFontSizeToFitWidth = false
        subTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
        subTitleLabel.textColor = UIColor.lightGray
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subTitleLabel
    }()
    private var bigImageView: UIImageView = {
        let bigImageView = UIImageView()
        bigImageView.contentMode = .scaleAspectFill
        bigImageView.layer.masksToBounds = true
        bigImageView.translatesAutoresizingMaskIntoConstraints = false
        return bigImageView
    }()
    
    private var starStackView: UIStackView = {
        let starStackView = UIStackView()
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.alignment = .fill
        starStackView.spacing = 20
        starStackView.contentMode = .scaleAspectFit
        starStackView.isUserInteractionEnabled = true
        starStackView.translatesAutoresizingMaskIntoConstraints = false

        return starStackView
    }()
    
    private var oneStarImageView: UIImageView = {
        let oneStarImageView = UIImageView()
        oneStarImageView.contentMode = .scaleAspectFit
        oneStarImageView.layer.masksToBounds = true
        oneStarImageView.translatesAutoresizingMaskIntoConstraints = false
        oneStarImageView.tag = 1
        return oneStarImageView
    }()
    
    private var twoStarImageView: UIImageView = {
        let twoStarImageView = UIImageView()
        twoStarImageView.contentMode = .scaleAspectFit
        twoStarImageView.layer.masksToBounds = true
        twoStarImageView.translatesAutoresizingMaskIntoConstraints = false
        twoStarImageView.tag = 2
        return twoStarImageView
    }()
    
    private var threeStarImageView: UIImageView = {
        let threeStarImageView = UIImageView()
        threeStarImageView.contentMode = .scaleAspectFit
        threeStarImageView.layer.masksToBounds = true
        threeStarImageView.translatesAutoresizingMaskIntoConstraints = false
        threeStarImageView.tag = 3
        return threeStarImageView
    }()
    
    private var fourStarImageView: UIImageView = {
        let fourStarImageView = UIImageView()
        fourStarImageView.contentMode = .scaleAspectFit
        fourStarImageView.layer.masksToBounds = true
        fourStarImageView.translatesAutoresizingMaskIntoConstraints = false
        fourStarImageView.tag = 4
        return fourStarImageView
    }()
    
    private var fiveStarImageView: UIImageView = {
        let fiveStarImageView = UIImageView()
        fiveStarImageView.contentMode = .scaleAspectFit
        fiveStarImageView.layer.masksToBounds = true
        fiveStarImageView.translatesAutoresizingMaskIntoConstraints = false
        fiveStarImageView.tag = 5
        return fiveStarImageView
    }()
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        
        jsonContent = CTUtiltiy.loadContentData(data: data)

        self.addGestureReconizerToImageView()
        createView()
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    
    func checkForiOS12(){
        if #available(iOS 12.0, *) {
            // no change in loading view
        }else{
            // change in view to have basic template
           templateDl1 = ""
        }
    }
    
    func viewWithoutImage(){
        contentView.addSubview(starStackView)
        activateStarStackViewContraints()
        
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight() + 50
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    func viewWithoutRating(){
        contentView.addSubview(bigImageView)
        imageViewBottomContraint = 20.0
        self.activateImageViewContraints()
        
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + getCaptionHeight() - 50
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight()
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    func viewWithoutImageandRating(){
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    func viewWithImageandRating(){
        contentView.addSubview(bigImageView)
        contentView.addSubview(starStackView)
        imageViewBottomContraint = 70.0
        activateImageViewContraints()
        activateStarStackViewContraints()

        let viewWidth = view.frame.size.width
        let viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight() + 44 // padding
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    
    func addGestureReconizerToImageView(){
        let tapGR1 = UITapGestureRecognizer(target: self, action: #selector(selectStar))
        tapGR1.delegate = self
        oneStarImageView.isUserInteractionEnabled = true
        oneStarImageView.addGestureRecognizer(tapGR1)
        
        let tapGR2 = UITapGestureRecognizer(target: self, action: #selector(selectStar))
        tapGR2.delegate = self
        twoStarImageView.isUserInteractionEnabled = true
        twoStarImageView.addGestureRecognizer(tapGR2)

        let tapGR3 = UITapGestureRecognizer(target: self, action: #selector(selectStar))
        tapGR3.delegate = self
        threeStarImageView.isUserInteractionEnabled = true
        threeStarImageView.addGestureRecognizer(tapGR3)
        
        let tapGR4 = UITapGestureRecognizer(target: self, action: #selector(selectStar))
        tapGR3.delegate = self
        fourStarImageView.isUserInteractionEnabled = true
        fourStarImageView.addGestureRecognizer(tapGR4)
        
        let tapGR5 = UITapGestureRecognizer(target: self, action: #selector(selectStar))
        tapGR5.delegate = self
        fiveStarImageView.isUserInteractionEnabled = true
        fiveStarImageView.addGestureRecognizer(tapGR5)
        
    }

    @objc func selectStar(_ sender: UITapGestureRecognizer){
        var deepLink:String?
        switch sender.view?.tag{
        case 1:
            oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            twoStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            threeStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            deepLink = jsonContent?.pt_dl1
            break
        case 2:
            oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            threeStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            deepLink = jsonContent?.pt_dl2
            break
        case 3:
            oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            deepLink = jsonContent?.pt_dl3
            break
        case 4:
            oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fourStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
            deepLink = jsonContent?.pt_dl4
            break
        case 5:
            oneStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            twoStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            threeStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fourStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            fiveStarImageView.image = UIImage(named: "ct_star_filled", in: Bundle(for: type(of: self)), compatibleWith: nil)
            deepLink = jsonContent?.pt_dl5
            break
        default:
            break
        }
        
        if let url = deepLink{
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
    
    func createView() {
        viewWithoutImageandRating()
        
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(titleLabel)
        
        oneStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        twoStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        threeStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fourStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)
        fiveStarImageView.image = UIImage(named: "ct_star_outline", in: Bundle(for: type(of: self)), compatibleWith: nil)

        starStackView.addArrangedSubview(oneStarImageView)
        starStackView.addArrangedSubview(twoStarImageView)
        starStackView.addArrangedSubview(threeStarImageView)
        starStackView.addArrangedSubview(fourStarImageView)
        starStackView.addArrangedSubview(fiveStarImageView)
        
        guard let jsonContent = jsonContent else {
            return
        }
        
        if let title = jsonContent.pt_title, !title.isEmpty{
            templateCaption = title
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty{
            templateSubcaption = msg
        }
        if let msgSummary = jsonContent.pt_msg_summary, !msgSummary.isEmpty{
            templateSubcaption = msgSummary
        }
        if let deeplink = jsonContent.pt_default_dl, !deeplink.isEmpty{
            deeplinkURL = deeplink
        }
        if let dl1 = jsonContent.pt_dl1, !dl1.isEmpty{
            templateDl1 = dl1
            updateUI()
        }
        if let bigImage = jsonContent.pt_big_img, !bigImage.isEmpty{
            templateBigImage = bigImage
        }
        
        self.titleLabel.text = templateCaption
        self.subTitleLabel.text = templateSubcaption
    
        if let bigImg = jsonContent.pt_big_img{
            CTUtiltiy.checkImageUrlValid(imageUrl: bigImg) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        self?.bigImageView.image = imageData
                        self?.updateUI()
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
            self.updateUI()
        }
                
        if let bgColor = jsonContent.pt_bg,!bgColor.isEmpty{
            view.backgroundColor = UIColor(hex: bgColor)
        }
        if let titleColor = jsonContent.pt_title_clr {
            self.titleLabel.textColor = UIColor(hex: titleColor)
        }
        if let msgColor = jsonContent.pt_msg_clr {
            self.subTitleLabel.textColor = UIColor(hex: msgColor)
        }
        
    }
    
    func updateUI(){
        checkForiOS12()
        if templateBigImage == "" && templateDl1 == ""{
            viewWithoutImageandRating()
        }else if templateBigImage == ""{
            viewWithoutImage()
        }else if templateDl1 == ""{
            viewWithoutRating()
        }else{
            viewWithImageandRating()
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            titleLabel.bottomAnchor.constraint(equalTo: subTitleLabel.topAnchor, constant: -8),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            subTitleLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)])
    }
    
    func activateImageViewContraints() {
        NSLayoutConstraint.activate([
            bigImageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 10),
            bigImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            bigImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            bigImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -imageViewBottomContraint)
        ])
    }
    
    func activateStarStackViewContraints(){
        NSLayoutConstraint.activate([
            starStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            starStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            starStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            starStackView.heightAnchor.constraint(equalToConstant: 30),
            
            oneStarImageView.heightAnchor.constraint(equalToConstant: 30),
            oneStarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            twoStarImageView.heightAnchor.constraint(equalToConstant: 30),
            twoStarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            threeStarImageView.heightAnchor.constraint(equalToConstant: 30),
            threeStarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            fourStarImageView.heightAnchor.constraint(equalToConstant: 30),
            fourStarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            fiveStarImageView.heightAnchor.constraint(equalToConstant: 30),
            fiveStarImageView.widthAnchor.constraint(equalToConstant: 50)
            
        ])
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
    
    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
