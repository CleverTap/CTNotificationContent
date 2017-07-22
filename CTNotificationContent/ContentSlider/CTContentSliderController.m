
#import "CTContentSliderController.h"
#import "CTCaptionedImageView.h"

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

@interface CTContentSliderController () {
    CGFloat captionHeight;
}

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray<NSDictionary*> *items;
@property (nonatomic, strong) NSMutableArray<CTCaptionedImageView*> *itemViews;
@property (nonatomic, strong) CTCaptionedImageView *currentItemView;
@property (nonatomic, assign) long currentItemIndex;

@property (nonatomic, assign) BOOL transitioning;
@property (nonatomic, assign) BOOL showsPaging;
@property (nonatomic, assign) BOOL autoPlays;
@property (nonatomic, assign) BOOL autoDismiss;

@end

@implementation CTContentSliderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = [[UIView alloc] initWithFrame:self.view.frame];
    captionHeight = [CTCaptionedImageView captionHeight]; // the height of the caption view below the image
    [self.view addSubview:self.contentView];
}

/**
 example userInfo looks like this
 {"ct_ContentSlider":
    {"orientation":"landscape",
    "showsPaging":1,
    "autoPlay":1,
    "autoDismiss":1,
    "items":[
        {"caption":"caption one",
        "subcaption":"subcaption one",
        "imageUrl":"https://9to5mac.files.wordpress.com/2015/10/apple-tv-screensaver.jpg?quality=82&w=1600&h=900",
        "actionUrl":"com.clevertap.ctcontent.example://item/one"},
        {"caption":"caption two",
        "subcaption":"subcaption two",
        "imageUrl":"https://i.ytimg.com/vi/0VFI90Bf3z8/maxresdefault.jpg",
        "actionUrl":"com.clevertap.ctcontent.example://item/two"}
        ]
    }
 }
 
*/

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
    
    if (config == nil) return;
    
    NSArray *items = config[kItemsKey];
    if (items && [items isKindOfClass:[NSString class]]) {
        NSString *_jsonString = (NSString *)items;
        NSData *i = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        items = [NSJSONSerialization JSONObjectWithData:i options:0 error:&error];
        
        if (error) {
            items = nil;
        }
    }
    
    if (items == nil) return;
    
    self.items = items;
    
    NSString *orientation = config[kOrientationKey];
    // assume square image orientation
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth + captionHeight;
    
    if ([orientation isEqualToString:kOrientationLandscape]) {
        viewHeight = (viewWidth*kLandscapeMultiplier) + captionHeight;
    }
    
    CGRect frame = CGRectMake(0, 0, viewWidth, viewHeight);
    self.view.frame = frame;
    self.contentView.frame = frame;
    self.preferredContentSize = CGSizeMake(viewWidth, viewHeight);
    
    for (UIView *view in _itemViews) {
        [view.superview removeFromSuperview];
    }
    
    self.itemViews = [NSMutableArray new];
    
    for (NSDictionary *item in items) {
        NSString *caption = item[kCaptionKey];
        NSString *subcaption = item[kSubCaptionKey];
        NSString *imageUrl = item[kImageUrlKey];
        NSString *actionUrl = item[kActionUrlKey];
        
        if (imageUrl == nil) {
            continue;
        }
        
        CTCaptionedImageView *itemView = [[CTCaptionedImageView alloc] initWithFrame:self.view.frame
                                                                             caption:caption
                                                                          subcaption:subcaption
                                                                            imageUrl:imageUrl
                                                                           actionUrl:actionUrl];
        [self.itemViews addObject:itemView];
    }
    
    
    self.autoPlays = [config[kAutoPlayKey] boolValue];
    self.autoDismiss = [config[kAutoDismissKey] boolValue];
    self.showsPaging = [config[kShowsPagingKey] boolValue];
    
    if (self.showsPaging) {
        if (self.pageControl == nil) {
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, viewHeight-(captionHeight+kPageControlViewHeight), viewWidth, kPageControlViewHeight)];
            self.pageControl.numberOfPages = [self.itemViews count];
            self.pageControl.hidesForSinglePage = YES;
            [self.view addSubview:self.pageControl];
        }
        
    } else {
        if (self.pageControl != nil) {
            [self.pageControl removeFromSuperview];
        }
    }
    
    [self showNext];
    
    if (self.autoPlays) {
        [self startAutoPlay];
    } else {
        [self stopAutoPlay];
    }
}

- (UNNotificationContentExtensionResponseOption)handleAction:(NSString *)action {
    // maps to go back 1
    if ([action isEqualToString:kAction1]) {
        [self stopAutoPlay];
        [self showPrevious];
        
    }
    // maps to go forward 1
    else if ([action isEqualToString:kAction2]) {
        [self stopAutoPlay];
        [self showNext];
    }
    // maps to run the relevant deeplink
    else if ([action isEqualToString:kAction3]) {
        if ([self.itemViews count] > 0) {
            NSString *urlString = self.itemViews[self.currentItemIndex].actionUrl;
            if (urlString) {
                [[self getParentViewController] userDidPerformAction:kOpenedContentUrlAction withProperties:self.items[self.currentItemIndex]];
                NSURL *url = [NSURL URLWithString:urlString];
                [[self getParentViewController] openUrl:url];
                return self.autoDismiss ?  UNNotificationContentExtensionResponseOptionDismiss : UNNotificationContentExtensionResponseOptionDoNotDismiss;
            }
        }
        //no deep link, so bail: forward action and dismiss
        return UNNotificationContentExtensionResponseOptionDismissAndForwardAction;
    }
    
    return UNNotificationContentExtensionResponseOptionDoNotDismiss;
}

- (void)showNext {
    [self _moveSlider:1];
}

- (void)showPrevious {
    [self _moveSlider:-1];
}

- (void)_moveSlider:(int)direction {
    long numItems = [self.itemViews count];
    
    if (self.transitioning || numItems <= 0) return;
    
    self.transitioning = YES;
    
    UIView *oldView = self.currentItemView;
    
    if (oldView == nil) {
        self.currentItemIndex = 0;
    } else {
        self.currentItemIndex += direction;
        if (self.currentItemIndex >= numItems) {
            self.currentItemIndex = 0;
        } else if (self.currentItemIndex < 0) {
            self.currentItemIndex = (numItems-1);
        }
    }
    
    self.currentItemView = self.itemViews[self.currentItemIndex];
    
    if (!self.currentItemView) return;
    
    if (self.pageControl) {
        self.pageControl.currentPage = self.currentItemIndex;
    }
    
    if (oldView && numItems > 1) {
        [UIView transitionFromView:oldView toView:self.currentItemView duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            self.transitioning = NO;
                        }];
        
    } else {
        [self.contentView addSubview:self.currentItemView];
        self.transitioning = NO;
    }
    
    [[self getParentViewController] userDidPerformAction:kViewContentItemAction withProperties:self.items[self.currentItemIndex]];
}

- (void)startAutoPlay {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kAutoPlayInterval
                                                      target:self
                                                    selector:@selector(showNext)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)stopAutoPlay {
    [self.timer invalidate];
    self.timer = nil;
}

@end
