//
//  Extensions.swift
//  CTNotificationContent
//
//  Created by Kushagra Mishra on 04/10/24.
//  Copyright © 2024 CleverTap. All rights reserved.
//
import Foundation
import UIKit

extension UILabel {
    func setHTMLText(_ htmlText: String) {
        let pointSize = self.font?.pointSize ?? UIFont.systemFontSize
        let modifiedFont = NSString(format: "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(pointSize)\">%@</span>" as NSString, htmlText) as String
        guard let data = modifiedFont.data(using: .unicode) else {
            CTContentLog.error("HTML to unicode data encode failed, rendering plain text, text=\(htmlText)")
            self.text = htmlText
            return
        }
        do {
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)
            self.attributedText = attributedString
        } catch {
            CTContentLog.error("HTML parse failed, rendering plain text, text=\(htmlText), error=\(error.localizedDescription)")
            self.text = htmlText
        }
    }

    // UILabel.textColor is ignored when attributedText has explicit foreground color
    // attributes (as HTML-parsed strings always do). This method applies the color
    // directly to the attributed string so it takes effect.
    func setTextColor(_ color: UIColor?) {
        guard let color = color else { return }
        guard let attributed = attributedText else {
            textColor = color
            return
        }
        let mutable = NSMutableAttributedString(attributedString: attributed)
        mutable.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: mutable.length))
        attributedText = mutable
    }
}
