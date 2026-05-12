import UIKit

class CTTimerBoxView: UIView {

    var timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = false
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: topAnchor),
            timerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        gradientLayer?.cornerRadius = layer.cornerRadius
    }

    func applyStyle(properties: TimerTemplateProperties, isDarkMode: Bool) {
        // Corner radius
        if let radiusStr = properties.pt_chrono_border_radius,
           let radius = Double(radiusStr) {
            layer.cornerRadius = CGFloat(radius)
            clipsToBounds = true
        }

        // Border width
        if let widthStr = properties.pt_chrono_border_width,
           let width = Double(widthStr) {
            layer.borderWidth = CGFloat(width)
        }

        // Border color
        if let hex = properties.pt_chrono_border_clr {
            layer.borderColor = UIColor(hex: hex)?.cgColor
        }

        // Timer text color
        let textClrHex = isDarkMode
            ? (properties.pt_chrono_title_clr_dark ?? properties.pt_chrono_title_clr)
            : properties.pt_chrono_title_clr
        if let hex = textClrHex {
            timerLabel.textColor = UIColor(hex: hex)
        }

        let style = properties.pt_chrono_style?.lowercased() ?? "solid"
        let isGradient = style == "gradient_linear" || style == "gradient_radial"

        if isGradient,
           let startHex = properties.pt_chrono_grad_clr1,
           let endHex = properties.pt_chrono_grad_clr2,
           let c1 = UIColor(hex: startHex), let c2 = UIColor(hex: endHex) {
            gradientLayer?.removeFromSuperlayer()
            let grad = CAGradientLayer()
            grad.frame = bounds
            grad.cornerRadius = layer.cornerRadius
            grad.colors = [c1.cgColor, c2.cgColor]

            if style == "gradient_radial" {
                grad.type = .radial
                grad.startPoint = CGPoint(x: 0.5, y: 0.5)
                grad.endPoint   = CGPoint(x: 1.0, y: 1.0)
            } else {
                let angleStr = properties.pt_chrono_grad_dir ?? "90"
                if let degrees = Double(angleStr.trimmingCharacters(in: .whitespaces)) {
                    let radians = degrees * .pi / 180.0
                    let endX = 0.5 + 0.5 * sin(radians)
                    let endY = 0.5 - 0.5 * cos(radians)
                    grad.startPoint = CGPoint(x: 1.0 - endX, y: 1.0 - endY)
                    grad.endPoint   = CGPoint(x: endX, y: endY)
                } else {
                    grad.startPoint = CGPoint(x: 0, y: 0.5)
                    grad.endPoint   = CGPoint(x: 1, y: 0.5)
                }
            }

            layer.insertSublayer(grad, at: 0)
            gradientLayer = grad
            backgroundColor = .clear
        } else {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil

            if let hex = properties.pt_chrono_bg_clr {
                backgroundColor = UIColor(hex: hex)
            }
        }
    }
}
