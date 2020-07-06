#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CleverTapSDK/CleverTap.h>

@implementation NotificationViewController

- (void)viewDidLoad {
    self.contentType = CTNotificationContentTypeContentSlider;  // CTNotificationContentTypeContentSlider is the default, just here for illustration
    [super viewDidLoad];
}

// optional: implement to get user event type data
- (void)userDidPerformAction:(NSString *)action withProperties:(NSDictionary *)properties {
    NSLog(@"user did perform action: %@ with props: %@", action , properties);
}

// optional: implement to get notification response
- (void)userDidReceiveNotificationResponse:(UNNotificationResponse *)response {
    id notificationPayload = response.notification.request.content.userInfo;
    if ([response.actionIdentifier  isEqual: @"action_@"]) {
        [[CleverTap sharedInstance] recordNotificationClickedEventWithData:notificationPayload];
    }
}

@end
