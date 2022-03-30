import UIKit
import UserNotificationsUI
import AVKit
import AVFoundation

class CTSingleMediaController: BaseCTNotificationContentViewController {
    var contentView: UIView = UIView(frame: .zero)
    var currentItemView: CTCaptionedImageView = CTCaptionedImageView(frame: .zero)
    var caption: String = ""
    var subCaption: String = ""
    var mediaType: String = ""
    var mediaURL: String = ""
    var deeplinkURL: String = ""
    var player:AVPlayer?
    var videoPlayerView: CTVideoPlayerView = CTVideoPlayerView(frame: .zero)
    private var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textAlignment = .left
        captionLabel.adjustsFontSizeToFitWidth = false
        captionLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        captionLabel.textColor = UIColor.black
        return captionLabel
    }()
    private var subcaptionLabel: UILabel = {
        let subcaptionLabel = UILabel()
        subcaptionLabel.textAlignment = .left
        subcaptionLabel.adjustsFontSizeToFitWidth = false
        subcaptionLabel.font = UIFont.systemFont(ofSize: 12.0)
        subcaptionLabel.textColor = UIColor.lightGray
        return subcaptionLabel
    }()
    var playImage: UIImage = UIImage()
    var pauseImage: UIImage = UIImage()
    var playPauseButton: UIButton = UIButton(frame: .zero)
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView(frame: view.frame)
        view.addSubview(contentView)

        let viewWidth = view.frame.size.width
        var viewHeight = viewWidth + getCaptionHeight()
        // For view in Landscape
        viewHeight = (viewWidth * (Constraints.kLandscapeMultiplier)) + getCaptionHeight()

        let frame: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = frame
        contentView.frame = frame
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)

        if mediaType == ConstantKeys.kMediaTypeVideo || mediaType == ConstantKeys.kMediaTypeAudio {
            createVideoView()
        } else {
            createImageView()
        }
    }
    
    func createVideoView() {
        let urlToVideo = URL(string: mediaURL)!
        let player = AVPlayer(url: urlToVideo)

        videoPlayerView.player = player
        captionLabel.text = caption
        subcaptionLabel.text = subCaption
        
        contentView.addSubview(videoPlayerView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(subcaptionLabel)
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = contentView.frame.size.height - getCaptionHeight()
        NSLayoutConstraint.activate([
            videoPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -Constraints.kImageBorderWidth),
            videoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Constraints.kImageBorderWidth),
            videoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constraints.kImageBorderWidth),
            videoPlayerView.heightAnchor.constraint(equalToConstant: imageHeight),
            
            captionLabel.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: Constraints.kCaptionTopPadding),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            captionLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subcaptionLabel.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: Constraints.kCaptionHeight + Constraints.kSubCaptionTopPadding),
            subcaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            subcaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)
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
    }
    
    func createImageView() {
        let itemComponents = CaptionedImageViewComponents(caption: caption, subcaption: subCaption, imageUrl: mediaURL, actionUrl: deeplinkURL, bgColor: ConstantKeys.kDefaultColor, captionColor: ConstantKeys.kHexBlackColor, subcaptionColor: ConstantKeys.kHexLightGrayColor)
        currentItemView = CTCaptionedImageView(components: itemComponents)
        contentView.addSubview(currentItemView)
        currentItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            currentItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            currentItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currentItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    override func handleAction(action: String) -> UNNotificationContentExtensionResponseOption {
        if action == ConstantKeys.kAction3 {
            // Maps to run the relevant deeplink
            if deeplinkURL != "" {
                let url = URL(string: deeplinkURL)!
                getParentViewController().openUrl(url: url)
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
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
}
