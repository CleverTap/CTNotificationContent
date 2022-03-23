import UIKit

fileprivate enum Constants {
    static let kCaptionHeight: CGFloat = 18.0
    static let kSubCaptionHeight: CGFloat = 20.0
    static let kSubCaptionTopPadding: CGFloat = 8.0
    static let kBottomPadding: CGFloat = 18.0
    static let kCaptionLeftPadding: CGFloat = 10.0
    static let kCaptionTopPadding: CGFloat = 8.0
    static let kImageBorderWidth: CGFloat = 1.0
    static let kImageLayerBorderWidth: CGFloat = 0.4
}

class CTCaptionedImageView : UIView {
    static var captionHeight: CGFloat = 0.0

    var actionUrl: String = ""
    private var caption: String = ""
    private var subcaption: String = ""
    private var imageUrl: String = ""

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = Constants.kImageLayerBorderWidth
        imageView.layer.masksToBounds = true
        return imageView
    }()
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

    init(caption: String, subcaption: String, imageUrl: String, actionUrl: String) {
        super.init(frame: .zero)
        
        self.caption = caption
        self.subcaption = subcaption
        self.imageUrl = imageUrl
        self.actionUrl = actionUrl
        setUpViews()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getCaptionHeight() -> CGFloat {
        if captionHeight <= 0 {
            captionHeight = Constants.kCaptionHeight + Constants.kSubCaptionHeight + Constants.kBottomPadding
        }
        return captionHeight
    }
    
    func setUpViews() {
        addSubview(imageView)
        addSubview(captionLabel)
        addSubview(subcaptionLabel)

        loadImage()
        captionLabel.text = caption
        subcaptionLabel.text = subcaption
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = frame.size.height - CTCaptionedImageView.getCaptionHeight()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: -Constants.kImageBorderWidth),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -Constants.kImageBorderWidth),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.kImageBorderWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight),
            
            captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.kCaptionTopPadding),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.kCaptionLeftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.kCaptionLeftPadding),
            captionLabel.heightAnchor.constraint(equalToConstant: Constants.kCaptionHeight),
            
            subcaptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.kCaptionHeight + Constants.kSubCaptionTopPadding),
            subcaptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.kCaptionLeftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.kCaptionLeftPadding),
            subcaptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constants.kSubCaptionHeight)
        ])
    }
    
    func loadImage() {
        if imageUrl == "" {
            return
        }
        
        let url = URL(string: imageUrl)!
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data {
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
        dataTask.resume()
    }
}
