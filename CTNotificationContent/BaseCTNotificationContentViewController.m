#import "BaseCTNotificationContentViewController.h"
#import "CTNotificationViewController.h"

@interface BaseCTNotificationContentViewController ()

@end

@implementation BaseCTNotificationContentViewController

- (UNNotificationContentExtensionResponseOption)handleAction:(NSString *)action {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (CTNotificationViewController *)getParentViewController {
    return (CTNotificationViewController*)self.parentViewController;
}

@end
