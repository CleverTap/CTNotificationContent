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
        let modifiedFont = NSString(format: "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>" as NSString, htmlText) as String
        guard let data = modifiedFont.data(using: .unicode) else { return }
        do {
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)
            self.attributedText = attributedString
        } catch {
            print("Error setting HTML text: \\(error.localizedDescription)")
            self.text = htmlText
        }
    }
}
