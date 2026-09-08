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
    @objc public var mediaDescription: String = CTAccessibility.kDefaultImageDescription
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

        CTContentLog.info("Single media controller started, mediaType=\(mediaType.isEmpty ? "nil" : mediaType), url=\(mediaURL)")

        if mediaType == ConstantKeys.kMediaTypeVideo || mediaType == ConstantKeys.kMediaTypeAudio {
            CTContentLog.info("mediaType video and audio not supported yet, rendering caption only, url=\(mediaURL)")
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
            CTContentLog.error("Media url parse failed, rendering caption only, url=\(mediaURL)")
            createFrameWithoutImage()
            return
        }

        if AVAsset(url: urlToVideo).isPlayable {
            CTContentLog.info("Media is playable, rendering player")
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
            
            let bundle = Bundle(for: type(of: self))
            if let image = UIImage(named: "ct_play_button", in: bundle, compatibleWith: nil) {
                playImage = image
            } else {
                CTContentLog.error("Missing bundle asset ct_play_button, play button has no icon")
            }
            if let image = UIImage(named: "ct_pause_button", in: bundle, compatibleWith: nil) {
                pauseImage = image
            } else {
                CTContentLog.error("Missing bundle asset ct_pause_button, pause button has no icon")
            }

            playPauseButton.setImage(pauseImage, for: .normal)
            playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
            playPauseButton.accessibilityLabel = "Pause"
            playPauseButton.accessibilityHint = "Pauses the video"
            playPauseButton.accessibilityTraits = .button
            playPauseButton.accessibilityIdentifier = CTAccessibility.kSingleMediaPlayPauseButtonIdentifier
            playPauseButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(playPauseButton)
            contentView.bringSubviewToFront(playPauseButton)

            NSLayoutConstraint.activate([
                playPauseButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                playPauseButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
                playPauseButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44.0),
                playPauseButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
            ])
        } else {
            CTContentLog.error("Media is not playable, rendering caption only, url=\(mediaURL)")
            createFrameWithoutImage()
        }
    }

    func createImageView() {
        CTUtiltiy.checkImageUrlValid(imageUrl: mediaURL) { [weak self] (imageData) in
            DispatchQueue.main.async {
                guard let self = self else {
                    CTContentLog.error("Controller deallocated before image arrived")
                    return
                }
                if imageData != nil {
                    CTContentLog.info("Image rendered, url=\(self.mediaURL)")
                    let itemComponents = CaptionedImageViewComponents(caption: self.caption, subcaption: self.subCaption, imageUrl: self.mediaURL, actionUrl: self.deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor, bgColorDark: ConstantKeys.kDefaultColorDark, captionColorDark: ConstantKeys.kHexWhiteColor, subcaptionColorDark: ConstantKeys.kHexDarkGrayColor, imageDescription: self.mediaDescription)
                    self.currentItemView = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
                } else {
                    CTContentLog.error("Image load failed, rendering caption only, url=\(self.mediaURL)")
                    let itemComponents = CaptionedImageViewComponents(caption: self.caption, subcaption: self.subCaption, imageUrl: "", actionUrl: self.deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor, imageDescription: "")
                    self.currentItemView = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
                    self.createFrameWithoutImage()
                }
                self.setUpConstraints()
            }
        }

        let itemComponents = CaptionedImageViewComponents(caption: caption, subcaption: subCaption, imageUrl: mediaURL, actionUrl: deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor, imageDescription: mediaDescription)
        currentItemView = CTCaptionedImageView(components: itemComponents, isGifSupported: false)
        
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
        captionLabel.setHTMLText(caption)
        subcaptionLabel.setHTMLText(subCaption)
        
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
            if deeplinkURL.isEmpty {
                CTContentLog.info("No deeplink, dismissing")
            } else if let url = URL(string: deeplinkURL) {
                CTContentLog.info("Opening deeplink, url=\(deeplinkURL)")
                getParentViewController()?.open(url)
            } else {
                CTContentLog.error("Deeplink parse failed, url=\(deeplinkURL)")
            }
            return .dismiss
        }
        return .doNotDismiss
    }
    
    @objc func playPauseButtonTapped(_ sender:UIButton) {
        if isPlaying {
            videoPlayerView.player?.pause()
            playPauseButton.setImage(playImage, for: .normal)
            playPauseButton.accessibilityLabel = "Play"
            playPauseButton.accessibilityHint = "Plays the video"
            isPlaying = false
        } else {
            videoPlayerView.player?.play()
            playPauseButton.setImage(pauseImage, for: .normal)
            playPauseButton.accessibilityLabel = "Pause"
            playPauseButton.accessibilityHint = "Pauses the video"
            isPlaying = true
        }
    }
    
    @objc public override func getDeeplinkUrl() -> String! {
        return deeplinkURL
    }
}
