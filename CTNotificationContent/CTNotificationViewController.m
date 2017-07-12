
#import "CTNotificationViewController.h"
#import "BaseCTNotificationContentViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "CTContentSliderController.h"

@interface CTNotificationViewController () <UNNotificationContentExtension>

@property(nonatomic, strong, readwrite) BaseCTNotificationContentViewController *contentViewController;

@end


@implementation CTNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    BaseCTNotificationContentViewController *contentController;
    
    switch (self.contentType) {
        case CTNotificationContentTypeContentSlider:
            contentController = [[CTContentSliderController alloc] init];
            break;
        default:
            break;
    }
    
    if (contentController != nil) {
        [self displayContentController:contentController];
    }
}

- (void)didReceiveNotification:(UNNotification *)notification {
    [self.contentViewController configureViewForContent:notification.request.content];
    self.view.frame = self.contentViewController.view.frame;
    self.preferredContentSize = self.contentViewController.preferredContentSize;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response
                     completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    UNNotificationContentExtensionResponseOption actionResponseOption = [self.contentViewController handleAction:response.actionIdentifier];
    completion(actionResponseOption);
}

- (void)displayContentController: (BaseCTNotificationContentViewController *) contentController {
    if (self.contentViewController != nil) {
        return;
    }
    [self addChildViewController:contentController];
    contentController.view.frame = self.view.frame;
    [self.view addSubview:contentController.view];
    [contentController didMoveToParentViewController:self];
    self.contentViewController = contentController;
}


- (void)userDidPerformAction:(NSString *)action withProperties:(NSDictionary *)properties {
    // no-op here
    // implement in your subclass to get user event type data
}

// convenience 
- (void)openUrl:(NSURL *)url {
    [self.extensionContext openURL:url completionHandler:nil];
}

@end
