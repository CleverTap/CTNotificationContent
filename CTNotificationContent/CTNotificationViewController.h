
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CTNotificationContentType) {
    CTNotificationContentTypeContentSlider = 0,
};

@interface CTNotificationViewController : UIViewController

@property(nonatomic, assign) CTNotificationContentType contentType; // set this in your subclass viewDidLoad before calling super to determine the content view to display

- (void)userDidPerformAction:(NSString * _Nonnull)action withProperties:(NSDictionary * _Nullable)properties;  // implement in your subclass to get user event type data

- (void)openUrl:(NSURL * _Nonnull)url; // convenience method

@end
