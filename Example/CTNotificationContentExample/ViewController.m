#import "ViewController.h"
#if __has_include(<CleverTapSDK/CleverTap.h>)
#import <CleverTapSDK/CleverTap.h>
#else
#import "CleverTap.h"
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendBasicTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"BasicTemplate_NotificationSent"];
}

- (IBAction)sendCarouselTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"CarouselTemplate_NotificationSent"];
}

- (IBAction)sendTimerTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"TimerTemplate_NotificationSent"];
}

- (IBAction)sendCustomBasicTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"CutomBasicTemplate_NotificationSent"];
}

- (IBAction)sendCustomAutoCarouselTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"CustomAutoCarouselTemplate_NotificationSent"];
}

- (IBAction)sendCustomManualTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"CustomManualCarouselTemplate_NotificationSent"];
}

- (IBAction)sendVideoMediaTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"VideoMediaTemplate_NotificationSent"];
}

- (IBAction)sendZeroBezelTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"ZeroBezelTemplate_NotificationSent"];
}
- (IBAction)sendWebViewTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"WebViewTemplate_NotificationSent"];
}

- (IBAction)sendProductDisplay_LinearTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"ProductDisplay_LinearTemplate_NotificationSent"];
}

- (IBAction)sendProductDisplay_VerticalTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"ProductDisplay_VerticalTemplate_NotificationSent"];
}

- (IBAction)sendRatingTemplate:(id)sender {
    [[CleverTap sharedInstance] recordEvent:@"RatingTemplate_NotificationSent"];
}

@end
