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
        if let radiusStr = properties.pt_timer_border_radius,
           let radius = Double(radiusStr) {
            layer.cornerRadius = CGFloat(radius)
            clipsToBounds = true
        }

        // Border width
        if let widthStr = properties.pt_timer_border_width,
           let width = Double(widthStr) {
            layer.borderWidth = CGFloat(width)
        }

        // Border color
        let borderClrHex = isDarkMode
            ? (properties.pt_timer_border_color_dark ?? properties.pt_timer_border_color)
            : properties.pt_timer_border_color
        if let hex = borderClrHex {
            layer.borderColor = UIColor(hex: hex)?.cgColor
        }

        // Timer text color
        let textClrHex = isDarkMode
            ? (properties.pt_timer_text_clr_dark ?? properties.pt_timer_text_clr)
            : properties.pt_timer_text_clr
        if let hex = textClrHex {
            timerLabel.textColor = UIColor(hex: hex)
        }

        // Background: gradient takes priority over solid color
        let gradStartHex = isDarkMode
            ? (properties.pt_timer_bg_gradient_start_dark ?? properties.pt_timer_bg_gradient_start)
            : properties.pt_timer_bg_gradient_start
        let gradEndHex = isDarkMode
            ? (properties.pt_timer_bg_gradient_end_dark ?? properties.pt_timer_bg_gradient_end)
            : properties.pt_timer_bg_gradient_end

        if let startHex = gradStartHex, let endHex = gradEndHex,
           let c1 = UIColor(hex: startHex), let c2 = UIColor(hex: endHex) {
            gradientLayer?.removeFromSuperlayer()
            let grad = CAGradientLayer()
            grad.frame = bounds
            grad.cornerRadius = layer.cornerRadius
            grad.colors = [c1.cgColor, c2.cgColor]

            let gradientType = properties.pt_timer_bg_gradient_type?.lowercased() ?? "linear"
            if gradientType == "radial" {
                grad.type = .radial
                grad.startPoint = CGPoint(x: 0.5, y: 0.5)
                grad.endPoint   = CGPoint(x: 1.0, y: 1.0)
            } else {
                let angleStr = properties.pt_timer_bg_gradient_angle ?? "90"
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

            let bgHex = isDarkMode
                ? (properties.pt_timer_bg_dark ?? properties.pt_timer_bg)
                : properties.pt_timer_bg
            if let hex = bgHex {
                backgroundColor = UIColor(hex: hex)
            }
        }
    }
}
