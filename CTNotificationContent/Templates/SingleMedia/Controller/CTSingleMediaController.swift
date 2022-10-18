import UIKit
import UserNotificationsUI
import AVKit
import AVFoundation

@objc public class CTSingleMediaController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    @objc public var caption: String = ""
    @objc public var subCaption: String = ""
    @objc public var mediaType: String = ""
    @objc public var mediaURL: String = ""
    @objc public var deeplinkURL: String = ""
    var player:AVPlayer?
    var videoPlayerView: CTVideoPlayerView = CTVideoPlayerView(frame: .zero)
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
    var playImage: UIImage = UIImage()
    var pauseImage: UIImage = UIImage()
    var playPauseButton: UIButton = UIButton(frame: .zero)
    var isPlaying: Bool = false
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        createFrameWithImage()

        if mediaType == ConstantKeys.kMediaTypeVideo || mediaType == ConstantKeys.kMediaTypeAudio {
            // TODO: Remove mediaURL = "" when video template is supported.
            mediaURL = ""
            createVideoView()
        } else {
            createImageView()
        }
    }
    
    func createVideoView() {
        createBasicCaptionView()

        guard let urlToVideo = URL(string: mediaURL) else {
            createFrameWithoutImage()
            return
        }
        
        if AVAsset(url: urlToVideo).isPlayable {
            let player = AVPlayer(url: urlToVideo)

            videoPlayerView.player = player
            
            contentView.addSubview(videoPlayerView)
            videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
            let imageHeight = contentView.frame.size.height - CTUtiltiy.getCaptionHeight()
            NSLayoutConstraint.activate([
                videoPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -Constraints.kImageBorderWidth),
                videoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Constraints.kImageBorderWidth),
                videoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constraints.kImageBorderWidth),
                videoPlayerView.heightAnchor.constraint(equalToConstant: imageHeight)
            ])

            videoPlayerView.player?.play()
            isPlaying = true
            
            playImage = UIImage(named: "ct_play_button", in: Bundle(for: type(of: self)), compatibleWith: nil)!
            pauseImage = UIImage(named: "ct_pause_button", in: Bundle(for: type(of: self)), compatibleWith: nil)!

            playPauseButton.setImage(pauseImage, for: .normal)
            playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
            playPauseButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(playPauseButton)
            contentView.bringSubviewToFront(playPauseButton)
            
            NSLayoutConstraint.activate([
                playPauseButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                playPauseButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor)
            ])
        } else {
            // Video url is invalid.
            createFrameWithoutImage()
        }
    }
    
    func createImageView() {
        CTUtiltiy.checkImageUrlValid(imageUrl: mediaURL) { [weak self] (imageData) in
            DispatchQueue.main.async {
                if imageData != nil {
                    let itemComponents = CaptionedImageViewComponents(caption: self!.caption, subcaption: self!.subCaption, imageUrl: self!.mediaURL, actionUrl: self!.deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor)
                    self?.currentItemView = CTCaptionedImageView(components: itemComponents)
                } else {
                    let itemComponents = CaptionedImageViewComponents(caption: self!.caption, subcaption: self!.subCaption, imageUrl: "", actionUrl: self!.deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor)
                    self?.currentItemView = CTCaptionedImageView(components: itemComponents)
                    self?.createFrameWithoutImage()
                }
                self?.setUpConstraints()
            }
        }
        
        let itemComponents = CaptionedImageViewComponents(caption: caption, subcaption: subCaption, imageUrl: mediaURL, actionUrl: deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor)
        currentItemView = CTCaptionedImageView(components: itemComponents)
        
    }
    
    func setUpConstraints() {
        contentView.addSubview(currentItemView)
        currentItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            currentItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            currentItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currentItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
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
    
    func createBasicCaptionView() {
        contentView.addSubview(captionLabel)
        contentView.addSubview(subcaptionLabel)
        captionLabel.text = caption
        subcaptionLabel.text = subCaption
        
        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CTUtiltiy.getCaptionHeight() - Constraints.kCaptionTopPadding)),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kTimerLabelWidth),
            captionLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subcaptionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(Constraints.kSubCaptionHeight + Constraints.kSubCaptionTopPadding)),
            subcaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kTimerLabelWidth),
            subcaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)
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
    
    @objc func playPauseButtonTapped(_ sender:UIButton) {
        if isPlaying {
            videoPlayerView.player?.pause()
            playPauseButton.setImage(playImage, for: .normal)
            isPlaying = false
        } else {
            videoPlayerView.player?.play()
            playPauseButton.setImage(pauseImage, for: .normal)
            isPlaying = true
        }
    }
    
    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
