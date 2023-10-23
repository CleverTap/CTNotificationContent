#import <UIKit/UIKit.h>

@interface CTNotificationViewController : UIViewController

- (void)userDidPerformAction:(NSString * _Nonnull)action withProperties:(NSDictionary * _Nullable)properties;  // implement in your subclass to get user event type data

- (void)openUrl:(NSURL * _Nonnull)url; // convenience method

- (void)userDidReceiveNotificationResponse:(UNNotificationResponse *_Nullable)response; // implement in your subclass to get notification response

@end
