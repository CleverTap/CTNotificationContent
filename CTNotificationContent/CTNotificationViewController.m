#import "CTNotificationViewController.h"
#import "BaseCTNotificationContentViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <CTNotificationContent/CTNotificationContent-Swift.h>

typedef NS_ENUM(NSInteger, CTNotificationContentType) {
    CTNotificationContentTypeContentSlider = 0,
    CTNotificationContentTypeSingleMedia = 1,
    CTNotificationContentTypeBasicTemplate = 2,
    CTNotificationContentTypeAutoCarousel = 3,
    CTNotificationContentTypeManualCarousel = 4,
    CTNotificationContentTypeTimerTemplate = 5,
    CTNotificationContentTypeZeroBezel = 6
};

static NSString * const kTemplateId = @"pt_id";
static NSString * const kContentSlider = @"ct_ContentSlider";
static NSString * const kTemplateBasic = @"pt_basic";
static NSString * const kTemplateAutoCarousel = @"pt_carousel";
static NSString * const kTemplateManualCarousel = @"pt_manual_carousel";
static NSString * const kTemplateTimer = @"pt_timer";
static NSString * const kSingleMediaType = @"ct_mediaType";
static NSString * const kSingleMediaURL = @"ct_mediaUrl";
static NSString * const kJSON = @"pt_json";
static NSString * const kDeeplinkURL = @"wzrk_dl";
static NSString * const kTemplateZeroBezel = @"pt_zero_bezel";

@interface CTNotificationViewController () <UNNotificationContentExtension>

@property(nonatomic, assign) CTNotificationContentType contentType;
@property(nonatomic, strong, readwrite) BaseCTNotificationContentViewController *contentViewController;
@property(nonatomic) NSString *jsonString;

@end

@implementation CTNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSDictionary *content = notification.request.content.userInfo;
    [self updateContentType:content];
    
    switch (self.contentType) {
        case CTNotificationContentTypeContentSlider: {
            CTContentSliderController *contentController = [[CTContentSliderController alloc] init];
            [contentController setData:content[kContentSlider]];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeSingleMedia: {
            CTSingleMediaController *contentController = [[CTSingleMediaController alloc] init];
            [contentController setCaption:notification.request.content.title];
            [contentController setSubCaption:notification.request.content.body];
            [contentController setMediaType:content[kSingleMediaType]];
            [contentController setMediaURL:content[kSingleMediaURL]];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeBasicTemplate: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [contentController setTemplateType:kTemplateBasic];
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeAutoCarousel: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [contentController setTemplateType:kTemplateAutoCarousel];
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeManualCarousel: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [contentController setTemplateType:kTemplateManualCarousel];
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeTimerTemplate: {
            CTTimerTemplateController *contentController = [[CTTimerTemplateController alloc] init];
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        case CTNotificationContentTypeZeroBezel: {
            CTZeroBezelController *contentController = [[CTZeroBezelController alloc] init];
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubCaption:notification.request.content.body];
            if (content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:content[kDeeplinkURL]];
            }
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;

        default:
            break;
    }
    
    self.view.frame = self.contentViewController.view.frame;
    self.preferredContentSize = self.contentViewController.preferredContentSize;
}

- (void)updateContentType:(NSDictionary *)content {
    if (content[kContentSlider] != nil) {
        self.contentType = CTNotificationContentTypeContentSlider;
    } else {
        if (content[kTemplateId] != nil) {
            if (content[kJSON] != nil) {
                self.jsonString = content[kJSON];
            } else {
                self.jsonString = [self createJSONData:content];
            }

            if ([content[kTemplateId] isEqualToString:kTemplateBasic]) {
                self.contentType = CTNotificationContentTypeBasicTemplate;
            } else if ([content[kTemplateId] isEqualToString:kTemplateAutoCarousel]) {
                self.contentType = CTNotificationContentTypeAutoCarousel;
            } else if ([content[kTemplateId] isEqualToString:kTemplateManualCarousel]) {
                self.contentType = CTNotificationContentTypeManualCarousel;
            } else if ([content[kTemplateId] isEqualToString:kTemplateTimer]) {
                self.contentType = CTNotificationContentTypeTimerTemplate;
            }else if ([content[kTemplateId] isEqualToString:kTemplateZeroBezel]) {
                self.contentType = CTNotificationContentTypeZeroBezel;
            } else {
                // Invalid pt_id value fallback to basic.
                self.contentType = CTNotificationContentTypeBasicTemplate;
            }
        } else if (content[kSingleMediaType] != nil && content[kSingleMediaURL] != nil) {
            self.contentType = CTNotificationContentTypeSingleMedia;
        } else {
            // Invalid payload data fallback to basic.
            self.contentType = CTNotificationContentTypeBasicTemplate;
        }
    }
}

- (NSString *)createJSONData:(NSDictionary *)content {
    // create JSON Data from individual keys provided.
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    for (NSString *key in content) {
        // Values received can be of NSNumber class, so keeping all values as NSString so that we can decode for type String in swift and typecast into our desired data types.
        NSString *value = content[key];
        [json setObject:value forKey:key];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    self.preferredContentSize = self.contentViewController.preferredContentSize;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response
                     completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    UNNotificationContentExtensionResponseOption actionResponseOption = [self.contentViewController handleAction:response.actionIdentifier];
    [self userDidReceiveNotificationResponse:response];
    completion(actionResponseOption);
}

- (void)userDidPerformAction:(NSString *)action withProperties:(NSDictionary *)properties {
    // no-op here
    // implement in your subclass to get user event type data
}

- (void)userDidReceiveNotificationResponse:(UNNotificationResponse *)response {
    // no-op here
    // implement in your subclass to get notification response
}

// convenience
- (void)openUrl:(NSURL *)url {
    [self.extensionContext openURL:url completionHandler:nil];
}

@end
