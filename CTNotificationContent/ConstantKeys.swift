import Foundation
import UIKit

//public enum CTNotificationContentType: Int {
//    case contentSlider = 0
////    case basicTemplate
////    case timerTemplate
//}
//protocol BaseCTNotificationViewController {
//    var selectedTemplate: UIViewController { get }
//}
struct GenericConstants {
    
    struct Keys {
        static let template = "ct_template"
        static let data = "ct_data"
    }
    
    struct Size {
        static let captionHeight: CGFloat = 18
        static let subCaptionHeight: CGFloat = 20
        static let subCaptionTopPadding: CGFloat = 8
        static let subCaptionBottomPadding: CGFloat = 18
        static let captionLeftPadding: CGFloat = 10
        static let captionTopPadding: CGFloat = 8
        static let imageBorderWidth: CGFloat = 1
        static let imageLayerBorderWidth: CGFloat = 0.4
        
        static let autoPlayInterval: CGFloat = 3
        static let landscapeMultiplier: CGFloat = 0.5625 // 16:9 in landscape
        static let pageControlViewHeight: CGFloat = 20
        static let pageControlBottomPadding: CGFloat = 0

    }
    
}
