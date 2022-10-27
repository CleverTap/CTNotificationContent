Pod::Spec.new do |s|
  s.name             = "CTNotificationContent"
  s.version          = "0.2.3"
  s.summary          = "A Notification Content Extension class to display custom content interfaces for iOS 10 push notifications"
  s.homepage         = "https://github.com/CleverTap/CTNotificationContent"
  s.license          = "MIT" 
  s.author           = { "CleverTap" => "http://www.clevertap.com" }
  s.source           = { :git => "https://github.com/CleverTap/CTNotificationContent.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.platform = :ios, '10.0'
  s.weak_frameworks = 'UserNotifications', 'UIKit'
  s.source_files = 'CTNotificationContent/**/*.{h,m,swift}'
  s.resources = 'CTNotificationContent/**/*.{png,xib}'
  s.swift_version = '5.0'
end
