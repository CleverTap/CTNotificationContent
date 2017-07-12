
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "CTNotificationViewController.h"

@interface BaseCTNotificationContentViewController : UIViewController

- (void)configureViewForContent:(UNNotificationContent *)content; // must override in subclass

- (UNNotificationContentExtensionResponseOption)handleAction:(NSString *)action;  // must override in subclass

- (CTNotificationViewController *)getParentViewController;


@end
