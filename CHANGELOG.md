Change Log
==========
Version 0.4.0 (19 May, 2025)
-----------------------------------------------
- Adds dark mode support for push templates
- Parses colour based on dark/light mode of phone

Version 0.3.0 (10 April, 2025)
-----------------------------------------------
- Added support for bold, italic, underline, and strikethrough HTML tags in title and message for rich push notifications.

Version 0.2.7 (17 April, 2024)
-----------------------------------------------
- Fixes a build error related to privacy manifests when statically linking the SDK using Cocoapods.
- Fixes the error "Missing an expected key: 'NSPrivacyCollectedDataTypes'" when generating a privacy report.
- Fixes a location mismatch between the podspec and the privacy manifest location.

Version 0.2.6 (20 March, 2024)
-----------------------------------------------
- Adds privacy manifests.

Version 0.2.5 (23 October, 2023)
-----------------------------------------------
- Fixes push notifications not being removed from notification center when clicked on expanded view.
- Fixes carousel not shown correctly for the first time when app is installed.

Version 0.2.4 (17 January, 2023)
-----------------------------------------------
- Adds support for importing from static libraries and frameworks.

Version 0.2.3 (28 October, 2022)
-----------------------------------------------
- Fixes a potential crash for the content slider template.

Version 0.2.2 (20 October, 2022)
-----------------------------------------------
- Supports new templates - Rating, Product Catalog and WebView

Version 0.2.1 (30 August, 2022)
-----------------------------------------------
- Supports a new template - Zero Bezel

Version 0.2.0 *(24 June, 2022)*
-----------------------------------------------
- Supports new templates - Basic, Auto carousel, Manual carousel and Timer
- Backward compatible with Rich Media Push Notifications (Single Image and Content Slider)
- Compatible with CleverTap iOS SDK v4.1.0

Version 0.1.5 *(3 December, 2021)*
-----------------------------------------------
- Adds support for installation via Swift Package Manager
- Update Starter Applications

Version 0.1.4 *(8 July, 2020)*
-------------------------------------------
- Add a method to return Push Notification response

Version 0.1.3 *(24 October, 2017)*
-------------------------------------------
- Update podspec to weak link UIkit framework to allow safe linking to < iOS 10 targets

Version 0.1.2 *(19 September, 2017)*
-------------------------------------------
- Update podspec to weak link UserNotifications framework to allow safe linking to < iOS 10 targets

Version 0.1.1 *(23 July, 2017)*
-------------------------------------------
- Add support for Back button in slideshow
- Add autoDismiss flag for granular control of notification dismissal on action url click
- Tweaks to item caption, subcaption, and imageview border display

Version 0.1.0 *(8 March, 2017)*
-------------------------------------------
- Initial release.
