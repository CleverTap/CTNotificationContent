#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "CTNotificationViewController.h"

@interface BaseCTNotificationContentViewController : UIViewController

- (UNNotificationContentExtensionResponseOption)handleAction:(NSString *)action;  // must override in subclass

- (NSString *)getDeeplinkUrl;  // must override in subclass

/// Returns nil when this controller is not attached to a CTNotificationViewController.
- (nullable CTNotificationViewController *)getParentViewController;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
