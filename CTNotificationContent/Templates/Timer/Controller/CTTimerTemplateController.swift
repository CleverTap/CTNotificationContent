import UIKit
import UserNotificationsUI

@objc public class CTTimerTemplateController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    @objc public var data: String = ""
    @objc public var templateCaption: String = ""
    @objc public var templateSubcaption: String = ""
    @objc public var deeplinkURL: String = ""
    var bgColor: String = ConstantKeys.kDefaultColor
    var captionColor: String = ConstantKeys.kHexBlackColor
    var subcaptionColor: String = ConstantKeys.kHexLightGrayColor
    var timerColor: String = ConstantKeys.kHexBlackColor
    var jsonContent: TimerTemplateProperties? = nil
    var timer: Timer = Timer()
    var thresholdSeconds = 0
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textAlignment = .left
        captionLabel.adjustsFontSizeToFitWidth = false
        captionLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        captionLabel.textColor = UIColor.black
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        return captionLabel
    }()
    private var subcaptionLabel: UILabel = {
        let subcaptionLabel = UILabel()
        subcaptionLabel.textAlignment = .left
        subcaptionLabel.adjustsFontSizeToFitWidth = false
        subcaptionLabel.font = UIFont.systemFont(ofSize: 12.0)
        subcaptionLabel.textColor = UIColor.lightGray
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return subcaptionLabel
    }()
    private var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.textAlignment = .center
        timerLabel.adjustsFontSizeToFitWidth = false
        timerLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        timerLabel.textColor = UIColor.black
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        return timerLabel
    }()
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        jsonContent = CTUtiltiy.loadContentData(data: data)
        createView()
        setupConstraints()
    }
    
    @objc public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func createView() {
        createFrameWithoutImage()
        contentView.addSubview(imageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(subcaptionLabel)
        contentView.addSubview(timerLabel)
        
        captionLabel.text = templateCaption
        subcaptionLabel.text = templateSubcaption

        guard let jsonContent = jsonContent else {
            return
        }
        if let threshold = jsonContent.pt_timer_threshold {
            thresholdSeconds = threshold
        } else {
            if let endTime = jsonContent.pt_timer_end {
                let date = NSDate()
                let currentTime = date.timeIntervalSince1970
                thresholdSeconds = endTime - Int(currentTime)
            }
        }

        if let title = jsonContent.pt_title, !title.isEmpty {
            captionLabel.text = title
        }
        if let msg = jsonContent.pt_msg, !msg.isEmpty {
            subcaptionLabel.text = msg
        }
        if let msgSummary = jsonContent.pt_msg_summary, !msgSummary.isEmpty {
            subcaptionLabel.text = msgSummary
        }
        if let bg = jsonContent.pt_bg, !bg.isEmpty {
            bgColor = bg
        }
        if let titleColor = jsonContent.pt_title_clr, !titleColor.isEmpty {
            captionColor = titleColor
        }
        if let msgColor = jsonContent.pt_msg_clr, !msgColor.isEmpty {
            subcaptionColor = msgColor
        }
        if let timerClr = jsonContent.pt_chrono_title_clr, !timerClr.isEmpty {
            timerColor = timerClr
        }
        if let action = jsonContent.pt_dl1, !action.isEmpty {
            deeplinkURL = action
        }
        if let bigImg = jsonContent.pt_big_img, !bigImg.isEmpty {
            if thresholdSeconds > 0 {
                // Load image only if timer is not ended.
                CTUtiltiy.checkImageUrlValid(imageUrl: bigImg) { [weak self] (imageData) in
                    DispatchQueue.main.async {
                        if imageData != nil {
                            self?.imageView.image = imageData
                            self?.activateImageViewContraints()
                            self?.createFrameWithImage()
                        }
                    }
                }
            }
        }

        view.backgroundColor = UIColor(hex: bgColor)
        imageView.backgroundColor = UIColor(hex: bgColor)
        captionLabel.textColor = UIColor(hex: captionColor)
        subcaptionLabel.textColor = UIColor(hex: subcaptionColor)
        timerLabel.textColor = UIColor(hex: timerColor)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() - Constraints.kCaptionTopPadding)),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kTimerLabelWidth),
            captionLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subcaptionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(Constraints.kSubCaptionHeight + Constraints.kSubCaptionTopPadding)),
            subcaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kTimerLabelWidth),
            subcaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight),
            
            timerLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CTUtiltiy.getCaptionHeight()),
            timerLabel.leadingAnchor.constraint(equalTo: captionLabel.trailingAnchor, constant: Constraints.kCaptionLeftPadding),
            timerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            timerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            timerLabel.heightAnchor.constraint(equalToConstant: CTUtiltiy.getCaptionHeight())
        ])
    }

    @objc func updateTimer() {
        let hr = thresholdSeconds / 3600
        let min = thresholdSeconds / 60 % 60
        let sec = thresholdSeconds % 60
        if thresholdSeconds > 0 {
            if hr < 1 {
                self.timerLabel.text = String(format: "%02i:%02i", min, sec)
            }
            else {
                self.timerLabel.text = String(format: "%02i:%02i:%02i", hr, min, sec)
            }
            thresholdSeconds -= 1
        } else {
            timer.invalidate()
            self.timerLabel.isHidden = true
            updateViewForExpiredTime()
        }
    }
    
    func updateViewForExpiredTime() {
        if let jsonContent = jsonContent {
            if let title = jsonContent.pt_title_alt, !title.isEmpty {
                captionLabel.text = title
            }
            if let msg = jsonContent.pt_msg_alt, !msg.isEmpty {
                subcaptionLabel.text = msg
            }
            if let altImage = jsonContent.pt_big_img_alt, !altImage.isEmpty {
                // Load expired image, if available.
                CTUtiltiy.checkImageUrlValid(imageUrl: altImage) { [weak self] (imageData) in
                    DispatchQueue.main.async {
                        if imageData != nil {
                                self?.imageView.image = imageData
                                self?.createFrameWithImage()
                                self?.activateImageViewContraints()
                        }
                    }
                }
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
    
    func activateImageViewContraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constraints.kImageBorderWidth),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CTUtiltiy.getCaptionHeight())
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
}
