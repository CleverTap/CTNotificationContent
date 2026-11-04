#import "BaseCTNotificationContentViewController.h"
#import "CTNotificationViewController.h"

#if __has_include(<CTNotificationContent/CTNotificationContent-Swift.h>)
#import <CTNotificationContent/CTNotificationContent-Swift.h>
#else
#import "CTNotificationContent-Swift.h"
#endif

#define CTContentLogInfo(fmt, ...) \
    [CTNotificationContentLogger logInfo:[NSString stringWithFormat:fmt, ##__VA_ARGS__] from:@(__PRETTY_FUNCTION__)]
#define CTContentLogError(fmt, ...) \
    [CTNotificationContentLogger logError:[NSString stringWithFormat:fmt, ##__VA_ARGS__] from:@(__PRETTY_FUNCTION__)]

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
    UIViewController *parent = self.parentViewController;
    if (parent == nil) {
        CTContentLogError(@"Nil parentViewController, cannot forward tap, controller=%@",
                          NSStringFromClass([self class]));
        return nil;
    }
    if (![parent isKindOfClass:[CTNotificationViewController class]]) {
        CTContentLogError(@"Expected CTNotificationViewController parent, got %@, cannot forward tap",
                          NSStringFromClass([parent class]));
        return nil;
    }
    return (CTNotificationViewController *)parent;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (@available(iOS 12.0, *)) {
        NSString *url = [self getDeeplinkUrl];
        if (!url || url.length == 0) {
            CTContentLogInfo(@"Tap with no deeplink, performing notification default action");
            [[self extensionContext] performNotificationDefaultAction];
            return;
        }
        NSURL *deeplink = [[NSURL alloc] initWithString:url];
        if (deeplink == nil) {
            CTContentLogError(@"Deeplink parse failed, performing notification default action, url=%@", url);
            [[self extensionContext] performNotificationDefaultAction];
            return;
        }
        CTContentLogInfo(@"Tap, opening deeplink, url=%@", url);
        [[self getParentViewController] openUrl:deeplink];
    } else {
        CTContentLogError(@"Tap handling requires iOS 12 or later, ignoring");
    }
}

@end
