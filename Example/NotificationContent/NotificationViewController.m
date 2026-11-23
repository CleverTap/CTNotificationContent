#import "NotificationViewController.h"
// The logger is a Swift class, and the umbrella header only covers the
// Objective-C ones.
#import <CTNotificationContent/CTNotificationContent-Swift.h>

@implementation NotificationViewController

- (void)viewDidLoad {
    // SDK logs are off by default. Debug builds of the sample turn on every
    // line, including whole payloads and full urls. This is set here, not
    // in the AppDelegate, because the extension runs in its own process.
#ifdef DEBUG
    [CTNotificationContentLogger setDebugLevel:1];
#endif
    [super viewDidLoad];
}

// optional: implement to get user event type data
- (void)userDidPerformAction:(NSString *)action withProperties:(NSDictionary *)properties {
    NSLog(@"user did perform action: %@ with props: %@", action , properties);
}

// optional: implement to get notification response
- (void)userDidReceiveNotificationResponse:(UNNotificationResponse *)response {
    NSLog(@"user did receive notification response: %@:", response);
}

@end
