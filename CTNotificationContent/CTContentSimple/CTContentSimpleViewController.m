//
//  CTContentSimpleViewController.m
//  CTNotificationContent
//
//  Created by Sonal Kachare on 26/11/21.
//  Copyright © 2021 CleverTap. All rights reserved.
//

#import "CTContentSimpleViewController.h"
static NSString * const kConfigKey = @"ct_ContentSlider";
static NSString * const kOrientationKey = @"orientation";
static NSString * const kOrientationLandscape = @"landscape";
static NSString * const kShowsPagingKey = @"showsPaging";
static NSString * const kAutoPlayKey = @"autoPlay";
static NSString * const kAutoDismissKey = @"autoDismiss";
static NSString * const kItemsKey = @"items";
static NSString * const kCaptionKey = @"caption";
static NSString * const kSubCaptionKey = @"subcaption";
static NSString * const kImageUrlKey = @"imageUrl";
static NSString * const kActionUrlKey = @"actionUrl";
static NSString * const kAction1 = @"action_1"; // Maps to Show Previous
static NSString * const kAction2 = @"action_2"; // Maps to Show Next
static NSString * const kAction3 = @"action_3"; // Maps to open the attached deeplink
static NSString * const kOpenedContentUrlAction = @"CTOpenedContentUrl";
static NSString * const kViewContentItemAction = @"CTViewedContentItem";
static const int kAutoPlayInterval = 3.0;
static const float kLandscapeMultiplier = 0.5625; // 16:9 in landscape
static const float kPageControlViewHeight = 20.f;


@interface CTContentSimpleViewController () {
    
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CTContentSimpleViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.contentView.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.contentView];
}

- (void)configureViewForContent:(UNNotificationContent *)content {
    NSDictionary *config = content.userInfo[kConfigKey];
    
    if (config && [config isKindOfClass:[NSString class]]) {
        NSString *_jsonString = (NSString *)config;
        NSData *_config = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        config = [NSJSONSerialization JSONObjectWithData:_config options:0 error:&error];
        
        if (error) {
            config = nil;
        }
    }
    
    
    NSString *orientation = config[kOrientationKey];
    // assume square image orientation
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth + 50;
    
    if ([orientation isEqualToString:kOrientationLandscape]) {
        viewHeight = (viewWidth*kLandscapeMultiplier) + 50;
    }
    
    CGRect frame = CGRectMake(0, 0, viewWidth, viewHeight);
    self.view.frame = frame;
    self.contentView.frame = frame;
    self.contentView.backgroundColor = UIColor.yellowColor;
    self.preferredContentSize = CGSizeMake(viewWidth, viewHeight);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
