//
//  CTZeroBezelController.swift
//  CTNotificationContent
//
//  Created by Aishwarya Nanna on 23/08/22.
//

import UIKit

@objc public class CTZeroBezelController: BaseCTNotificationContentViewController {

    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    
    var captionColor: String = ConstantKeys.kHexBlackColor
    var subcaptionColor: String = ConstantKeys.kHexLightGrayColor
    
    // Dark mode colors
    var captionColorDark: String = ConstantKeys.kHexWhiteColor
    var subcaptionColorDark: String = ConstantKeys.kHexDarkGrayColor

    var jsonContent: ZeroBezelProperties? = nil
    var templateBigImage:String = ""
    var templateDl1:String = ""
    
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
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)
        
        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        setupConstraints()
        
        // Register for trait changes on iOS 17+
        if #available(iOSApplicationExtension 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) {[weak self] (self: Self, previousTraitCollection: UITraitCollection) in
                self.updateInterfaceColors()
            }
        }
    }

    func createFrameWithoutImage() {
        let viewWidth = view.frame.size.width
        let viewHeight = CTUtiltiy.getCaptionHeight()
        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    
    func createFrameWithImage() {
        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + CTUtiltiy.getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + CTUtiltiy.getCaptionHeight()

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
    
    func createView() {
        createFrameWithoutImage()
        contentView.addSubview(bigImageView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(titleLabel)
        
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
        if let deeplink = jsonContent.pt_dl1, !deeplink.isEmpty{
            deeplinkURL = deeplink
        }
        if let bigImage = jsonContent.pt_big_img, !bigImage.isEmpty{
            templateBigImage = bigImage
        }
        
        self.titleLabel.setHTMLText(templateCaption)
        self.subTitleLabel.setHTMLText(templateSubcaption)
    
        if let bigImg = jsonContent.pt_big_img{
            CTUtiltiy.checkImageUrlValid(imageUrl: bigImg) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if imageData != nil {
                        self?.bigImageView.image = imageData
                        self?.activateImageViewContraints()
                        self?.createFrameWithImage()
                    }
                }
            }
        }
        
        if let titleColor = jsonContent.pt_title_clr, !titleColor.isEmpty {
            captionColor = titleColor
        }
        if let msgColor = jsonContent.pt_msg_clr, !msgColor.isEmpty {
            subcaptionColor = msgColor
        }

        if let titleColorDark = jsonContent.pt_title_clr_dark, !titleColorDark.isEmpty {
            captionColorDark = titleColorDark
        }
        if let msgColorDark = jsonContent.pt_msg_clr_dark, !msgColorDark.isEmpty {
            subcaptionColorDark = msgColorDark
        }

        updateInterfaceColors()

    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() - Constraints.kCaptionTopPadding)),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subTitleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(Constraints.kSubCaptionHeight + Constraints.kSubCaptionTopPadding)),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subTitleLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)])
    }
    
    func activateImageViewContraints() {
        NSLayoutConstraint.activate([
            bigImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bigImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bigImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bigImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
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
    
    @objc public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            // Only handle trait changes on iOS 16 and below
            // iOS 17+ uses registerForTraitChanges
            if #available(iOSApplicationExtension 17.0, *) {
                // Do nothing, handled by registerForTraitChanges
            } else if #available(iOSApplicationExtension 12.0, *) {
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
            // For iOS versions before 12.0,using light mode colors since dark mode wasn't officially supported
            isDarkMode = false
        }

        self.titleLabel.textColor = UIColor(hex: isDarkMode ? captionColorDark : captionColor)
        self.subTitleLabel.textColor = UIColor(hex: isDarkMode ? subcaptionColorDark : subcaptionColor)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

