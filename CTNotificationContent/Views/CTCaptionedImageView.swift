import UIKit

struct CaptionedImageViewComponents {
    var caption: String = ""
    var subcaption: String = ""
    var imageUrl: String = ""
    var actionUrl: String = ""
    var bgColor: String = ""
    var captionColor: String = ""
    var subcaptionColor: String = ""
}

class CTCaptionedImageView : UIView {
    var components = CaptionedImageViewComponents()

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = Constraints.kImageLayerBorderWidth
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textAlignment = .left
        captionLabel.adjustsFontSizeToFitWidth = false
        captionLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        return captionLabel
    }()
    private var subcaptionLabel: UILabel = {
        let subcaptionLabel = UILabel()
        subcaptionLabel.textAlignment = .left
        subcaptionLabel.adjustsFontSizeToFitWidth = false
        subcaptionLabel.font = UIFont.systemFont(ofSize: 12.0)
        return subcaptionLabel
    }()

    init(components: CaptionedImageViewComponents) {
        super.init(frame: .zero)

        self.components = components
        setUpViews()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCaptionHeight() -> CGFloat {
        return Constraints.kCaptionHeight + Constraints.kSubCaptionHeight + Constraints.kBottomPadding
    }
    
    func setUpViews() {
        backgroundColor = UIColor(hex: components.bgColor)

        addSubview(imageView)
        addSubview(captionLabel)
        addSubview(subcaptionLabel)

        loadImage()
        captionLabel.text = components.caption
        subcaptionLabel.text = components.subcaption
        captionLabel.textColor = UIColor(hex: components.captionColor)
        subcaptionLabel.textColor = UIColor(hex: components.subcaptionColor)
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        subcaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = frame.size.height - getCaptionHeight()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -Constraints.kImageBorderWidth),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constraints.kImageBorderWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight),
            
            captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constraints.kCaptionTopPadding),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            captionLabel.heightAnchor.constraint(equalToConstant: Constraints.kCaptionHeight),
            
            subcaptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constraints.kCaptionHeight + Constraints.kSubCaptionTopPadding),
            subcaptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constraints.kCaptionLeftPadding),
            subcaptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constraints.kCaptionLeftPadding),
            subcaptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constraints.kSubCaptionTopPadding),
            subcaptionLabel.heightAnchor.constraint(equalToConstant: Constraints.kSubCaptionHeight)
        ])
    }
    
    func loadImage() {
        // When imageUrl is empty or invalid display no image preview.
        let noImage = UIImage(named: "ct_no_image", in: Bundle(for: type(of: self)), compatibleWith: nil)
        if components.imageUrl.isEmpty {
            self.imageView.image = noImage
            return
        }
        
        let url = URL(string: components.imageUrl)!
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data {
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            } else {
                self?.imageView.image = noImage
            }
        }
        dataTask.resume()
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let red, green, blue: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    blue = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                    self.init(red: red, green: green, blue: blue, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }
}
