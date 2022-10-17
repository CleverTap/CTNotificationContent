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

- (NSString *)getDeeplinkUrl{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (CTNotificationViewController *)getParentViewController {
    return (CTNotificationViewController*)self.parentViewController;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (@available(iOS 12.0, *)) {
        NSString *url = [self getDeeplinkUrl];
        if (!url || url.length == 0) {
            [[self extensionContext] performNotificationDefaultAction];
        }else{
            [[self getParentViewController] openUrl:([[NSURL alloc] initWithString:url])];
        }
    } else {
        // Fallback on earlier versions
    }
}

@end
