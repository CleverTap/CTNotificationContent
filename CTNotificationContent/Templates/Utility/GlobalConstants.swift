enum TemplateConstants {
    static let kTemplateBasic: String = "pt_basic"
    static let kTemplateAutoCarousel: String = "pt_carousel"
    static let kTemplateManualCarousel: String = "pt_manual_carousel"
    static let kTemplateFiveIcons: String = "pt_five_icons"
}

enum Constraints {
    static let kCaptionHeight: CGFloat = 18.0
    static let kSubCaptionHeight: CGFloat = 20.0
    static let kSubCaptionTopPadding: CGFloat = 8.0
    static let kBottomPadding: CGFloat = 18.0
    static let kCaptionLeftPadding: CGFloat = 16.0
    static let kCaptionTopPadding: CGFloat = 8.0
    static let kImageBorderWidth: CGFloat = 1.0
    static let kImageLayerBorderWidth: CGFloat = 0.4
    static let kPageControlViewHeight: CGFloat = 20.0
    static let kTimerLabelWidth: CGFloat = 100.0
    static let kTimerLabelWidthWithHours: CGFloat = 120.0
    static let kTimerBoxHeight: CGFloat = 50.0
    static let kTimerBorderMaxWidth: CGFloat = 10.0
    static let kTimerHorizontalGap: CGFloat = 4.0
    static let kLandscapeMultiplier: CGFloat = 0.5625 // 16:9 in landscape
    static let kPortraitMultiplier: CGFloat = 1.777 // 16:9 in portrait

    // FiveIcons template
    static let kFiveIconsMinIcons: Int                = 3
    static let kFiveIconsMaxIcons: Int                = 5
    static let kFiveIconsTitleFontSize: CGFloat        = 16.0
    static let kFiveIconsMessageFontSize: CGFloat      = 14.0
    static let kFiveIconsTitleNumberOfLines: Int        = 1
    static let kFiveIconsMessageNumberOfLines: Int     = 2
    static let kFiveIconsHorizontalPadding: CGFloat   = 16.0
    static let kFiveIconsVerticalPadding: CGFloat     = 10.0
    static let kFiveIconsLabelSpacing: CGFloat        = 4.0
    static let kFiveIconsIconSpacing: CGFloat         = 10.0
    static let kFiveIconsThreeIconHInset: CGFloat     = 40.0
    static let kFiveIconsRowTopSpacing: CGFloat       = 8.0
    static let kFiveIconsRowBottomPadding: CGFloat    = 10.0
    static let kFiveIconsNoTextVerticalPad: CGFloat   = 24.0
}

enum ConstantKeys {
    // Light mode defaults
    static let kDefaultColor: String = "#FFFFFF"     // System background
    static let kHexBlackColor: String = "#000000"    // Primary text
    static let kHexLightGrayColor: String = "#8E8E93" // Secondary text
    
    // Dark mode defaults
    static let kDefaultColorDark: String = "#1C1C1E" // Dark mode background
    static let kHexWhiteColor: String = "#FFFFFF"    // Dark mode primary text
    static let kHexDarkGrayColor: String = "#AEAEB2" // Dark mode secondary text
    
    static let kAction1: String = "action_1" // Maps to Show Previous
    static let kAction2: String = "action_2" // Maps to Show Next
    static let kAction3: String = "action_3" // Maps to open the attached deeplink
    static let kMediaTypeVideo: String = "video"
    static let kMediaTypeImage: String = "image"
    static let kMediaTypeAudio: String = "audio"
    static let kOrientationLandscape: String = "landscape"
    static let kOpenedContentUrlAction: String = "CTOpenedContentUrl"
    static let kViewContentItemAction: String = "CTViewedContentItem"
}

enum CTAccessibility {
    static let kDefaultImageDescription: String = "Notification Image"
    static let kDefaultSmallImage1Description: String = "Notification Image 1"
    static let kDefaultSmallImage2Description: String = "Notification Image 2"
    static let kDefaultSmallImage3Description: String = "Notification Image 3"
    
    
    // Five Icons accessibility labels for imgs
    static let kDefaultIcon1Description: String = "Notification Icon 1"
    static let kDefaultIcon2Description: String = "Notification Icon 2"
    static let kDefaultIcon3Description: String = "Notification Icon 3"
    static let kDefaultIcon4Description: String = "Notification Icon 4"
    static let kDefaultIcon5Description: String = "Notification Icon 5"
}

