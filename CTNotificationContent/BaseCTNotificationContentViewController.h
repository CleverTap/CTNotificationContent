
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "CTNotificationViewController.h"

@interface BaseCTNotificationContentViewController : UIViewController

- (void)configureViewForContent:(UNNotificationContent *)content; // must override in subclass

- (BOOL)handleAction:(NSString *)action;  // must override in subclass

- (CTNotificationViewController *)getParentViewController;


@end
