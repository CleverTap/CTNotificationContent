#import "CTNotificationViewController.h"
#import "BaseCTNotificationContentViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#if __has_include(<CTNotificationContent/CTNotificationContent-Swift.h>)
#import <CTNotificationContent/CTNotificationContent-Swift.h>
#else
#import "CTNotificationContent-Swift.h"
#endif

typedef NS_ENUM(NSInteger, CTNotificationContentType) {
    CTNotificationContentTypeContentSlider = 0,
    CTNotificationContentTypeSingleMedia = 1,
    CTNotificationContentTypeBasicTemplate = 2,
    CTNotificationContentTypeAutoCarousel = 3,
    CTNotificationContentTypeManualCarousel = 4,
    CTNotificationContentTypeTimerTemplate = 5,
    CTNotificationContentTypeZeroBezel = 6,
    CTNotificationContentTypeWebView = 7,
    CTNotificationContentTypeProductDisplay = 8,
    CTNotificationContentTypeRating = 9
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
static NSString * const kTemplateWebView = @"pt_web_view";
static NSString * const kTemplateProductDisplay = @"pt_product_display";
static NSString * const kTemplateRating = @"pt_rating";

@interface CTNotificationViewController () <UNNotificationContentExtension>

@property(nonatomic, assign) CTNotificationContentType contentType;
@property(nonatomic, strong, readwrite) BaseCTNotificationContentViewController *contentViewController;
@property(nonatomic) NSString *jsonString;
@property(nonatomic) NSDictionary *content;
@property(nonatomic) UNNotification *notification;

@end

@implementation CTNotificationViewController
BOOL isFromProductDisplay = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveNotification:(UNNotification *)notification {
    _content = notification.request.content.userInfo;
    _notification = notification;

    [self updateContentType:_content];
    
    switch (self.contentType) {
        case CTNotificationContentTypeContentSlider: {
            CTContentSliderController *contentController = [[CTContentSliderController alloc] init];
            [contentController setData:_content[kContentSlider]];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (_content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:_content[kDeeplinkURL]];
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
            [contentController setMediaType:_content[kSingleMediaType]];
            [contentController setMediaURL:_content[kSingleMediaURL]];
            if (_content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:_content[kDeeplinkURL]];
            }
            [self addChildViewController:contentController];
            contentController.view.frame = self.view.frame;
            [self.view addSubview:contentController.view];
            self.contentViewController = contentController;
        }
            break;
        basic: case CTNotificationContentTypeBasicTemplate: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            if (isFromProductDisplay){
                [contentController setIsFromProductDisplay:true];
            }
            [contentController setData:self.jsonString];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (_content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:_content[kDeeplinkURL]];
            }
            [contentController setTemplateType:kTemplateBasic];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeAutoCarousel: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            [contentController setTemplateType:kTemplateAutoCarousel];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeManualCarousel: {
            CTCarouselController *contentController = [[CTCarouselController alloc] init];
            [contentController setTemplateType:kTemplateManualCarousel];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeTimerTemplate: {
            CTTimerTemplateController *contentController = [[CTTimerTemplateController alloc] init];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeZeroBezel: {
            CTZeroBezelController *contentController = [[CTZeroBezelController alloc] init];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeWebView: {
            CTWebViewController *contentController = [[CTWebViewController alloc] init];
            [self setupContentController:contentController];
        }
            break;
        case CTNotificationContentTypeProductDisplay: {
            if ([CTUtiltiy isRequiredKeysProvidedWithJsonString:self.jsonString]){
                BaseCTNotificationContentViewController *contentController = [CTUtiltiy getControllerTypeWithJsonString:self.jsonString];
                [self setupContentController:contentController];
            }else{
                isFromProductDisplay = true;
                goto basic;
            }
        }
            break;
        case CTNotificationContentTypeRating: {
            CTRatingsViewController *contentController = [[CTRatingsViewController alloc] init];
            [self setupContentController:contentController];
        }
            break;
        default:
            break;
    }
    
    self.view.frame = self.contentViewController.view.frame;
    self.preferredContentSize = self.contentViewController.preferredContentSize;
}

- (void)setupContentController:(id)contentController{
    [contentController setData:self.jsonString];
    [contentController setTemplateCaption:_notification.request.content.title];
    [contentController setTemplateSubcaption:_notification.request.content.body];
    if (_content[kDeeplinkURL] != nil) {
        [contentController setDeeplinkURL:_content[kDeeplinkURL]];
    }
    [self addChildViewController:contentController];
    [contentController view].frame = self.view.frame;
    [self.view addSubview:[contentController view]];
    self.contentViewController = contentController;
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
            }else if ([content[kTemplateId] isEqualToString:kTemplateWebView]) {
                self.contentType = CTNotificationContentTypeWebView;
            }else if ([content[kTemplateId] isEqualToString:kTemplateProductDisplay]) {
                self.contentType = CTNotificationContentTypeProductDisplay;
            }else if ([content[kTemplateId] isEqualToString:kTemplateRating]) {
                self.contentType = CTNotificationContentTypeRating;
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
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // IF THE DEEP LINK DIDNT WORK, OPEN PARENT APP
        if (!success) {
            if (@available(iOS 12.0, *)) {
                [self.extensionContext performNotificationDefaultAction];
            } else {
                // Fallback on earlier versions
            }
        }
        
        // This removes the clicked notification from Notification Center when clicked in expanded view.
        UNUserNotificationCenter *current = [UNUserNotificationCenter currentNotificationCenter];
        [current getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            NSString *notificationIdentifier;
            for (NSUInteger i = 0; i < [notifications count]; i++) {
                if ([notifications[i].request.identifier isEqualToString:self.notification.request.identifier]) {
                    notificationIdentifier = self.notification.request.identifier;
                    break;
                }
            }
            if (notificationIdentifier) {
                [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[notificationIdentifier]];
            }
        }];
    }];
}

@end
