# CTNotificationContent

[![Version](https://img.shields.io/cocoapods/v/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)
[![License](https://img.shields.io/cocoapods/l/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)
[![Platform](https://img.shields.io/cocoapods/p/CTNotificationContent.svg?style=flat)](http://cocoapods.org/pods/CTNotificationContent)

### A Notification Content Extension class to display custom content interfaces for iOS 10 push notifications

Starting with iOS 10 you can add custom content views to iOS push notifications.  This library provides a class to accomplish that.  It provides a default Image Slideshow view and is designed to be easily extensible to display additional view types. 

[Custom push notification content interfaces](https://developer.apple.com/videos/play/wwdc2016/708/) are enabled in iOS 10 via a [Notification Content Extension](https://developer.apple.com/reference/usernotificationsui/unnotificationcontentextension), a separate and distinct binary embedded in your app bundle.

### Configure your app for Push and add a Notification Content Extension target

Enable [push notifications](https://developer.apple.com/notifications/) in your main app.

Create a Notification Content Extension in your project. To do that in your Xcode project, select File -> New -> Target and choose the Notification Content Extension template.

![notification content extension](https://github.com/CleverTap/CTNotificationContent/blob/master/images/content_extension.png)


### Install CTNotificationContent in your Notification Content Extension target via [CocoaPods](http://cocoapods.org)

Your Podfile should look something like this:

    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '10.0'

    use_frameworks!

    target 'YOUR_NOTIFICATION_CONTENT_TARGET_NAME' do  
        pod 'CTNotificationContent'  
    end     

Then run `pod install`.

[See example Podfile here](https://github.com/CleverTap/CTNotificationContent/blob/master/Example/Podfile).

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

### Configure your APNS payload

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
        "mutable-content": 1,
      },
    "ct_ContentSlider: {
        "orientation":"landscape", // landscape assumes 16:9 images, remove to display default square/portrait images
        "showsPaging":1, // optional to display UIPageControl
        "autoPlay":1, // optional to auto play the slideshow
        "autoDismiss":1, // optional to auto dismiss the notification on item actionUrl launch
        "items":[
            {"caption":"caption one",
                "subcaption":"subcaption one",
                "imageUrl":"https://s3.amazonaws.com/ct-demo-images/landscape-1.jpg"
                "actionUrl":"com.clevertap.ctcontent.example://item/one"}, 
            {"caption":"caption two", 
                "subcaption":"subcaption two", 
                "imageUrl":"https://s3.amazonaws.com/ct-demo-images/landscape-2.jpg",
                "actionUrl":"com.clevertap.ctcontent.example://item/two"}
            ]
     }
}
```

See [an example Swift project here](https://github.com/CleverTap/CTNotificationContent/tree/master/ExampleSwift).


See [an example Objective-C project here](https://github.com/CleverTap/CTNotificationContent/tree/master/Example).
