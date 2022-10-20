
<p align="center">
  <img src="https://github.com/CleverTap/clevertap-ios-sdk/blob/master/docs/images/clevertap-logo.png" width = "50%"/>
</p>


# CTNotificationContent

[![Version](https://img.shields.io/cocoapods/v/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/cocoapods/p/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
[![License](https://img.shields.io/cocoapods/l/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)


### A Notification Content Extension class to display custom content interfaces for iOS 10 push notifications

Starting with iOS 10 you can add custom content views to iOS push notifications.  This library provides a class to accomplish that.  It provides a default Image Slideshow view and is designed to be easily extensible to display additional view types. 

[Custom push notification content interfaces](https://developer.apple.com/videos/play/wwdc2016/708/) are enabled in iOS 10 via a [Notification Content Extension](https://developer.apple.com/reference/usernotificationsui/unnotificationcontentextension), a separate and distinct binary embedded in your app bundle.

# Table of contents
- [Installation](#installation)
- [Setup](#setup)
- [Dashboard Usage](#dashboard-usage)
- [Template Types](#template-types)
- [Template Keys](#template-keys)
- [Sample App](#sample-app)
- [Changelog](#changelog)

# 🎉 Installation #
[(Back to top)](#table-of-contents)
## [CocoaPods](http://cocoapods.org)

Your Podfile should look something like this:

    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '10.0'

    use_frameworks!

    target 'YOUR_NOTIFICATION_CONTENT_TARGET_NAME' do  
        pod 'CTNotificationContent'  
    end     

Then run `pod install`

[See example Podfile here](https://github.com/CleverTap/CTNotificationContent/blob/master/Example/Podfile).

## Swift Package Manager

Swift Package Manager is an Xcode tool that installs project dependencies. To use it to install CTNotificationContent SDK, follow these steps:

- In Xcode, navigate to **File -> Swift Package Manager -> Add Package Dependency.**
- Enter **https://github.com/CleverTap/CTNotificationContent.git** when choosing package repo and Click **Next.**
- On the next screen, Select an SDK version (by default, Xcode selects the latest stable version). Click **Next.**
- Click **Finish** and ensure that the **CTNotificationContent** has been added to the appropriate target.

# 🚀 Setup #

[(Back to top)](#table-of-contents)
### Configure your app for Push and add a Notification Content Extension target

Enable [push notifications](https://developer.apple.com/notifications/) in your main app.

Create a Notification Content Extension in your project. To do that in your Xcode project, select File -> New -> Target and choose the Notification Content Extension template.

![notification content extension](https://github.com/CleverTap/CTNotificationContent/blob/master/images/content_extension.png)



### Configure your Notification Content Extension to use the CTNotificationViewController class

Change the superclass of your NotificationViewController to `CTNotificationViewController`. You should not implement any of the UNNotificationContentExtension protocol methods in your NotificationViewController class, those will be handled by `CTNotificationViewController`.  [See Objective-C example here](https://github.com/CleverTap/CTNotificationContent/tree/master/Example/NotificationContent) and [Swift example here](https://github.com/CleverTap/CTNotificationContent/tree/master/ExampleSwift/NotificationContent). 

Edit the `Maininterface.storyboard` in your NotificationContent target to a plain UIView, [see example here](https://github.com/CleverTap/CTNotificationContent/blob/master/Example/NotificationContent/Base.lproj/MainInterface.storyboard). 

In your AppDelegate, register the Notification category and actions:

Swift:
```Swift
    // register category with actions
    let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
    let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
    let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
    let category = UNNotificationCategory(identifier: "CTNotification", actions: [action1, action2, action3], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
```
Objective-C:
```Objc
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action_1" title:@"Back" options:UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action_2" title:@"Next" options:UNNotificationActionOptionNone];
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action_3" title:@"View In App" options:UNNotificationActionOptionNone];
    UNNotificationCategory *cat = [UNNotificationCategory categoryWithIdentifier:@"CTNotification" actions:@[action1, action2, action3] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [center setNotificationCategories:[NSSet setWithObjects:cat, nil]];
```

[See Objective-C example here](https://github.com/CleverTap/CTNotificationContent/blob/master/Example/CTNotificationContentExample/AppDelegate.m) and [Swift example here](https://github.com/CleverTap/CTNotificationContent/blob/master/ExampleSwift/CTNotificationContentExampleSwift/AppDelegate.swift).

Then configure your Notification Content target Info.plist to reflect the category identifier you registered: `NSExtension -> NSExtensionAttributes -> UNNotificationExtensionCategory`.  In addition, set the `UNNotificationExtensionInitialContentSizeRatio -> 0.1` and `UNNotificationExtensionDefaultContentHidden -> true`.  

Also, If you plan on downloading non-SSL urls please be sure to enable `App Transport Security Settings -> Allow Arbitrary Loads -> true` in your plist.  [See plist example here](https://github.com/CleverTap/CTNotificationContent/blob/master/Example/NotificationContent/Info.plist).  

# Dashboard Usage

[(Back to top)](#table-of-contents)
While creating a Push Notification campaign on CleverTap, just follow the steps below -

1. On the "WHAT" section pass the desired required values in the "title" and "message" fields (NOTE: These are iOS alert title and body).
![Dashboard alert](https://github.com/CleverTap/CTNotificationContent/blob/master/images/dashboard_alert.png)
2. Click on "Advanced" and then click on "Rich Media" and select Single or Carousel template.
![Dashboard Rich Media](https://github.com/CleverTap/CTNotificationContent/blob/master/images/dashboard_richMedia.png)
3. For adding custom key-value pair, add the [template Keys](#template-keys) individually or into one JSON object and use the `pt_json` key to fill in the values.
![Dashboard Custom Key individual](https://github.com/CleverTap/CTNotificationContent/blob/master/images/dashboard_customKeysIndividual.png)
![Dashboard Custom Key JSON](https://github.com/CleverTap/CTNotificationContent/blob/master/images/dashboard_customKeyValue.png)
4. Send a test push and schedule!

# Template Types

[(Back to top)](#table-of-contents)

## Rich Media
### Single Media
Single media is for basic view with single image.
![Single Media](https://github.com/CleverTap/CTNotificationContent/blob/master/images/SingleMedia.png)

### Content Slider
Content Slider is for image slideshow view where user can add multiple images with different captions, sub-captions, and actions.

<img src="https://github.com/CleverTap/CTNotificationContent/blob/master/images/ContentSlider.gif" alt="Content slider" width="450" height="800"/>

## Custom key-value pair

### Basic Template
Basic Template is the basic push notification received on apps where user can also update text colour, background colour.

![Custom Basic template](https://github.com/CleverTap/CTNotificationContent/blob/master/images/CustomBasicTemplate.png)

### Auto Carousel Template
Auto carousel is an automatic revolving carousel push notification where user can also update text colour, background colour.

<img src="https://github.com/CleverTap/CTNotificationContent/blob/master/images/CustomAutoCarousel.gif" alt="Auto carousel" width="450" height="800"/>

### Manual Carousel Template
This is the manual version of the carousel. The user can navigate to the next/previous image by clicking on the Next/Back buttons.
---
**NOTE:**

For iOS 12 and above, you need to configure your Notification Content target Info.plist to reflect the category identifier you registered: `NSExtension -> NSExtensionAttributes -> UNNotificationExtensionCategory`.  In addition, set the `UNNotificationExtensionInitialContentSizeRatio -> 0.1` ,  `UNNotificationExtensionDefaultContentHidden -> true` and `UNNotificationExtensionUserInteractionEnabled -> 1`.

For iOS 11 and below, the previous/next buttons will not work. Please use notification actions with identifiers `action_1` and `action_2` for this purpose.

---

<img src="https://github.com/CleverTap/CTNotificationContent/blob/master/images/CustomManualCarousel.gif" alt="Manual carousel" width="450" height="800"/>

### Timer Template
This template features a live countdown timer. You can even choose to show different title, message, and background image after the timer expires.

<img src="https://github.com/CleverTap/CTNotificationContent/blob/master/images/CustomTimerTemplate.gif" alt="Timer template" width="450" height="800"/>

### Zero Bezel Template

The Zero Bezel template ensures that the background image covers the entire available surface area of the push notification. All the text is overlayed on the image.

![Zero Bezel template](https://github.com/CleverTap/CTNotificationContent/blob/master/images/ZeroBezel.png)

### Rating Template

Rating template lets your users give you feedback.

**NOTE:**

For iOS 12 and above, you need to configure your Notification Content target Info.plist to reflect the category identifier you registered: `NSExtension -> NSExtensionAttributes -> UNNotificationExtensionCategory`.  In addition, set the `UNNotificationExtensionInitialContentSizeRatio -> 0.1` ,  `UNNotificationExtensionDefaultContentHidden -> true` and `UNNotificationExtensionUserInteractionEnabled -> 1`.
For iOS 11 and below, it will fallback to a basic template.

---

![Rating](https://github.com/CleverTap/CTNotificationContent/blob/master/images/Rating.gif)

### Product Catalog Template

Product catalog template lets you show case different images of a product (or a product catalog) before the user can decide to click on the "BUY NOW" option which can take them directly to the product via deep links. This template has two variants.

**NOTE:**

For iOS 12 and above, you need to configure your Notification Content target Info.plist to reflect the category identifier you registered: `NSExtension -> NSExtensionAttributes -> UNNotificationExtensionCategory`.  In addition, set the `UNNotificationExtensionInitialContentSizeRatio -> 0.1` ,  `UNNotificationExtensionDefaultContentHidden -> true` and `UNNotificationExtensionUserInteractionEnabled -> 1`.
For iOS 11 and below, it will fallback to a basic template.

---

### Vertical View 

![Product Display](https://github.com/CleverTap/CTNotificationContent/blob/master/images/ProductDisplayVertical.gif)

### Linear View

Use the following keys to enable linear view variant of this template.

Template Key | Required | Value
---:|:---:|:---
pt_product_display_linear | Optional | `true`

![Product Display](https://github.com/CleverTap/CTNotificationContent/blob/master/images/ProductDisplayLinear.gif)

### WebView Template 

WebView template lets you load a remote https URL.

![WebView Template](https://github.com/CleverTap/CTNotificationContent/blob/master/images/WebView.gif)

**Note:** If any image can't be downloaded, the template falls back to basic template with caption and sub caption only.

# Template Keys

[(Back to top)](#table-of-contents)

## Rich Media
### Content Slider
Configure your APNS payload:

Then, when sending notifications via [APNS](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html):
- include the mutable-content flag in your payload aps entry (this key must be present in the aps payload or the system will not call your app extension) 
- for the Image Slideshow view, add the `ct_ContentSlider` key with a json object value, see example below, to the payload, outside of the aps entry.



```
{

    "aps": {
        "alert": {
            "body": "test message",
            "title": "test title",
        },
        "category": "CTNotification",
        "mutable-content": true,
      },
    "ct_ContentSlider": {
        "orientation": "landscape", // landscape assumes 16:9 images, remove to display default square/portrait images
        "showsPaging": true, // optional to display UIPageControl
        "autoPlay": true, // optional to auto play the slideshow
        "autoDismiss": true, // optional to auto dismiss the notification on item actionUrl launch
        "items":[
            {
                "caption": "caption one",
                "subcaption": "subcaption one",
                "imageUrl": "https://s3.amazonaws.com/ct-demo-images/landscape-1.jpg",
                "actionUrl": "com.clevertap.ctcontent.example://item/one"
            }, 
            {
                "caption": "caption two", 
                "subcaption": "subcaption two", 
                "imageUrl": "https://s3.amazonaws.com/ct-demo-images/landscape-2.jpg",
                "actionUrl": "com.clevertap.ctcontent.example://item/two"
            }
       ]
   }
}
```
## Custom key-value pair

### Basic Template
Basic Template Keys | Required | Description
 ---:|:---:|:---| 
pt_id | Required | Value - `pt_basic`
pt_title | Required | Title
pt_msg | Required | Message
pt_msg_summary | Required | Message line when Notification is expanded
pt_bg | Required | Background Color in HEX
pt_big_img | Optional | Image
pt_dl1 | Optional | One Deep Link
pt_title_clr | Optional | Title Color in HEX
pt_msg_clr | Optional | Message Color in HEX
pt_json | Optional | Above keys in JSON format

### Auto Carousel Template

Auto Carousel Template Keys | Required | Description
  ---:|:---:|:--- 
pt_id | Required | Value - `pt_carousel`
pt_title | Required | Title
pt_msg | Required | Message
pt_msg_summary | Optional | Message line when Notification is expanded
pt_dl1 | Required | Deep Link
pt_img1 | Required | Image One
pt_img2 | Required | Image Two
pt_img3 | Required | Image Three
pt_bg | Required | Background Color in HEX
pt_title_clr | Optional | Title Color in HEX
pt_msg_clr | Optional | Message Color in HEX
pt_json | Optional | Above keys in JSON format

### Manual Carousel Template

Manual Carousel Template Keys | Required | Description
  ---:|:---:|:--- 
pt_id | Required | Value - `pt_manual_carousel`
pt_title | Required | Title
pt_msg | Required | Message
pt_msg_summary | Optional | Message line when Notification is expanded
pt_dl1 | Required | Deep Link One
pt_img1 | Required | Image One
pt_img2 | Required | Image Two
pt_img3 | Required | Image Three
pt_bg | Required | Background Color in HEX
pt_title_clr | Optional | Title Color in HEX
pt_msg_clr | Optional | Message Color in HEX
pt_json | Optional | Above keys in JSON format

### Timer Template

Timer Template Keys | Required | Description
  ---:|:---:|:--- 
pt_id | Required | Value - `pt_timer`
pt_title | Required | Title
pt_title_alt | Optional | Title to show after timer expires
pt_msg | Required | Message
pt_msg_alt | Optional | Message to show after timer expires
pt_msg_summary | Optional | Message line when Notification is expanded
pt_dl1 | Required | Deep Link
pt_big_img | Optional | Image
pt_big_img_alt | Optional | Image to show when timer expires
pt_bg | Required | Background Color in HEX
pt_chrono_title_clr | Optional | Color for timer text in HEX
pt_timer_threshold | Required | Timer duration in seconds. Will be given higher priority. 
pt_timer_end | Optional | Epoch Timestamp to countdown to (for example, $D_1595871380 or 1595871380). Not needed if pt_timer_threshold is specified.
pt_title_clr | Optional | Title Color in HEX
pt_msg_clr | Optional | Message Color in HEX
pt_json | Optional | Above keys in JSON format

### Zero Bezel Template
 
 Zero Bezel Template Keys | Required | Description 
  ---:|:---:|:--- 
  pt_id | Required | Value - `pt_zero_bezel`
  pt_title | Required | Title 
  pt_msg | Required | Message
  pt_msg_summary | Optional | Message line when Notification is expanded
  pt_subtitle | Optional | Subtitle
  pt_big_img | Required | Image
  pt_dl1 | Required | Deep Link
  pt_title_clr | Optional | Title Color in HEX
  pt_msg_clr | Optional | Message Color in HEX
  pt_json | Optional | Above keys in JSON format

### Rating Template

Rating Template Keys | Required | Description
 ---:|:---:|:--- 
pt_id | Required  | Value - `pt_rating`
pt_title | Required  | Title
pt_msg | Required  | Message
pt_big_img | Optional | Image
pt_msg_summary | Optional | Message line when Notification is expanded
pt_subtitle | Optional | Subtitle
pt_default_dl | Required  | Default Deep Link for Push Notification
pt_dl1 | Required  | Deep Link for first/all star(s)
pt_dl2 | Optional | Deep Link for second star
pt_dl3 | Optional | Deep Link for third star
pt_dl4 | Optional | Deep Link for fourth star
pt_dl5 | Optional | Deep Link for fifth star
pt_bg | Required  | Background Color in HEX
pt_ico | Optional | Large Icon
pt_title_clr | Optional | Title Color in HEX
pt_msg_clr | Optional | Message Color in HEX
pt_json | Optional | Above keys in JSON format

### Product Catalog Template

Product Catalog Template Keys | Required | Description
 ---:|:---:|:--- 
pt_id | Required  | Value - `pt_product_display`
pt_title | Required  | Title
pt_msg | Required  | Message
pt_subtitle | Optional  | Subtitle
pt_img1 | Required  | Image One
pt_img2 | Required  | Image Two
pt_img3 | Optional  | Image Three
pt_bt1 | Required  | Big text for first image
pt_bt2 | Required  | Big text for second image
pt_bt3 | Required  | Big text for third image
pt_st1 | Required  | Small text for first image
pt_st2 | Required  | Small text for second image
pt_st3 | Required  | Small text for third image
pt_dl1 | Required  | Deep Link for first image
pt_dl2 | Required  | Deep Link for second image
pt_dl3 | Required  | Deep Link for third image
pt_price1 | Required  | Price for first image
pt_price2 | Required  | Price for second image
pt_price3 | Required  | Price for third image
pt_bg | Required  | Background Color in HEX
pt_product_display_action | Required  | Action Button Label Text
pt_product_display_linear | Optional  | Linear Layout Template ("true"/"false")
pt_product_display_action_clr | Required  | Action Button Background Color in HEX
pt_title_clr | Optional  | Title Color in HEX
pt_msg_clr | Optional  | Message Color in HEX
pt_json | Optional  | Above keys in JSON format

### WebView Template

WebView Template Keys | Required | Description
 ---:|:---:|:--- 
pt_id | Required  | Value - `pt_web_view`
pt_dl1 | Required  | Deep Link
pt_url | Required  | URL to load
pt_orientation | Optional  | Value - `landscape` or `portrait`
pt_json | Optional  | Above keys in JSON format

# Sample App #

[(Back to top)](#table-of-contents)
- See [an example Swift project here](./ExampleSwift).

- See [an example Objective-C project here](./Example).

- See [an example SwiftPM project here](./ExampleSwiftPM).

# Changelog #

[(Back to top)](#table-of-contents)
Refer to the [Change Log](./CHANGELOG.md).

