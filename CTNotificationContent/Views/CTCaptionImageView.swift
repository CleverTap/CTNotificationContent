import UIKit
import AVKit
import AVFoundation


class CTCaptionImageView: UIViewController {
    var myData: String = ""
    var mybasictemplatebody: String = ""
    var mybasictemplatetitle: String = ""
    var mybasictemplatemediaUrl: String = ""
    var mybasictemplatemediaType: String = ""
    var playButton:UIButton?
    var player:AVPlayer?
    var videoPlayerView: VideoPlayerView?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var subcaption: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        if mybasictemplatemediaType == "video" {
        loadVideo()
        }
        if mybasictemplatemediaType == "image" {
        loadImage()
        }
        set_text();
    }
    func loadVideo() {
        let urlToVideo = URL(string: mybasictemplatemediaUrl)!
        let player = AVPlayer(url: urlToVideo)

        let playerFrame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height)
        videoPlayerView = VideoPlayerView(frame: playerFrame)
        videoPlayerView?.player = player
        videoPlayerView?.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(videoPlayerView!)

        player.play()
        
        //Add controls
        playButton = UIButton(type: UIButton.ButtonType.system) as UIButton
        let xPostion:CGFloat = 50
        let yPostion:CGFloat = 100
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 45
        
        playButton!.frame = CGRect(x: xPostion, y: yPostion, width: buttonWidth, height: buttonHeight)
        playButton!.backgroundColor = UIColor.lightGray
        playButton!.setTitle("Play", for: UIControl.State.normal)
        playButton!.tintColor = UIColor.black
        playButton!.addTarget(self, action: #selector(self.playButtonTapped(_:)), for: .touchUpInside)
        self.mainView.addSubview(playButton!)
        
    }
    
        @objc func playButtonTapped(_ sender:UIButton)
        {
            caption.text = "done re"
            playButton!.setTitle("Pause", for: UIControl.State.normal)
            videoPlayerView?.player?.pause()
//            if player?.rate == 0
//            {
//                player!.play()
//                //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
//                playButton!.setTitle("Pause", for: UIControl.State.normal)
//            } else {
//                player!.pause()
//                //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
//                playButton!.setTitle("Play", for: UIControl.State.normal)
//            }
        }

    func set_text() {
        caption.text = mybasictemplatebody
        caption.textColor = UIColor.red
        caption.textAlignment = .left
//        caption.shadowColor = UIColor.black
        caption.font = UIFont(name: "HelveticaNeue", size: CGFloat(18))
        subcaption.text = mybasictemplatetitle
        subcaption.textColor = UIColor.green
        subcaption.textAlignment = .left
        subcaption.font = UIFont(name: subcaption.font.fontName, size: 28)
    }
    func loadImage() {
    let imageURL = URL(string: mybasictemplatemediaUrl)!
        
        let backgroundImage : UIImageView = {
            let image = UIImageView(frame: .zero)
                image.layer.borderColor = UIColor.lightGray.cgColor
                image.layer.borderWidth = GenericConstants.Size.imageLayerBorderWidth
                image.translatesAutoresizingMaskIntoConstraints = false
                image.contentMode = .scaleAspectFit
                image.sd_setImage(with: imageURL)
                return image
            }()
        mainView.addSubview(backgroundImage)
//        mainView.backgroundColor = .gray
 
        if #available(iOSApplicationExtension 11.0, *) {
            NSLayoutConstraint.activate([
                backgroundImage.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor),
                backgroundImage.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor),
                backgroundImage.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor),
                backgroundImage.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
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
        super.init(nibName: "CTCaptionImageView", bundle: Bundle(for: CTCaptionImageView.self))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
