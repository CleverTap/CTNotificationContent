#import "CTNotificationViewController.h"
#import "BaseCTNotificationContentViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#if __has_include(<CTNotificationContent/CTNotificationContent-Swift.h>)
#import <CTNotificationContent/CTNotificationContent-Swift.h>
#else
#import "CTNotificationContent-Swift.h"
#endif

// Short names for the logger. __PRETTY_FUNCTION__ gives the class and the
// method, so the log line points at the exact place the message came from.
#define CTContentLogInfo(fmt, ...) \
    [CTNotificationContentLogger logInfo:[NSString stringWithFormat:fmt, ##__VA_ARGS__] from:@(__PRETTY_FUNCTION__)]
#define CTContentLogError(fmt, ...) \
    [CTNotificationContentLogger logError:[NSString stringWithFormat:fmt, ##__VA_ARGS__] from:@(__PRETTY_FUNCTION__)]

/// Name of a response option, for the logs. The raw values are 0, 1 and 2.
/// A name tells the reader what the extension asked the system to do.
static NSString *CTResponseOptionName(UNNotificationContentExtensionResponseOption option) {
    switch (option) {
        case UNNotificationContentExtensionResponseOptionDoNotDismiss:
            return @"doNotDismiss";
        case UNNotificationContentExtensionResponseOptionDismiss:
            return @"dismiss";
        case UNNotificationContentExtensionResponseOptionDismissAndForwardAction:
            return @"dismissAndForwardAction";
    }
    return [NSString stringWithFormat:@"unknown(%lu)", (unsigned long)option];
}

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
    CTNotificationContentTypeRating = 9,
    CTNotificationContentTypeVerticalImage = 10
};

static NSString * const kTemplateId = @"pt_id";
static NSString * const kContentSlider = @"ct_ContentSlider";
static NSString * const kTemplateBasic = @"pt_basic";
static NSString * const kTemplateAutoCarousel = @"pt_carousel";
static NSString * const kTemplateManualCarousel = @"pt_manual_carousel";
static NSString * const kTemplateTimer = @"pt_timer";
static NSString * const kSingleMediaType = @"ct_mediaType";
static NSString * const kSingleMediaURL = @"ct_mediaUrl";
static NSString * const kSingleMediaDescription = @"alt_text_wzrk_bp";
static NSString * const kJSON = @"pt_json";
static NSString * const kDeeplinkURL = @"wzrk_dl";
static NSString * const kTemplateZeroBezel = @"pt_zero_bezel";
static NSString * const kTemplateWebView = @"pt_web_view";
static NSString * const kTemplateProductDisplay = @"pt_product_display";
static NSString * const kTemplateRating = @"pt_rating";
static NSString * const kTemplateVerticalImage = @"pt_vertical_img";

@interface CTNotificationViewController () <UNNotificationContentExtension>

@property(nonatomic, assign) CTNotificationContentType contentType;
@property(nonatomic, strong, readwrite) BaseCTNotificationContentViewController *contentViewController;
@property(nonatomic) NSString *jsonString;
@property(nonatomic) NSDictionary *content;
@property(nonatomic) UNNotification *notification;

@end

@implementation CTNotificationViewController
BOOL isFromProductDisplay = false;

/// Reads a payload value that the Swift controllers expect as text.
/// The Swift properties are non optional, so a value of another type would
/// stop the extension. Empty text is returned instead.
static NSString *CTContentStringValue(NSDictionary *content, NSString *key) {
    id value = content[key];
    if (value == nil) {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    [CTNotificationContentLogger logError:[NSString stringWithFormat:@"Expected NSString for key=%@, got %@, using empty string", key, NSStringFromClass([value class])]
                                     from:@"CTContentStringValue"];
    return @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // First line the extension writes. If a report has no CTNotificationContent
    // lines at all, the system never started the extension. The cause is then
    // outside this SDK. Check that the target is embedded in the app. Check that
    // UNNotificationExtensionCategory matches the category in the payload.
    CTContentLogInfo(@"Extension view loaded, frame=%@", NSStringFromCGRect(self.view.frame));

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveNotification:(UNNotification *)notification {
    _content = notification.request.content.userInfo;
    _notification = notification;

    CTContentLogInfo(@"Received notification, id=%@, payloadKeys=[%@]",
                     notification.request.identifier,
                     [[_content allKeys] componentsJoinedByString:@", "]);

    [self updateContentType:_content];

    switch (self.contentType) {
        case CTNotificationContentTypeContentSlider: {
            CTContentSliderController *contentController = [[CTContentSliderController alloc] init];
            [contentController setData:CTContentStringValue(_content, kContentSlider)];
            [contentController setTemplateCaption:notification.request.content.title];
            [contentController setTemplateSubcaption:notification.request.content.body];
            if (_content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:CTContentStringValue(_content, kDeeplinkURL)];
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
            [contentController setMediaType:CTContentStringValue(_content, kSingleMediaType)];
            [contentController setMediaURL:CTContentStringValue(_content, kSingleMediaURL)];
            if (_content[kSingleMediaDescription] != nil) {
                [contentController setMediaDescription:CTContentStringValue(_content, kSingleMediaDescription)];
            }
            if (_content[kDeeplinkURL] != nil) {
                [contentController setDeeplinkURL:CTContentStringValue(_content, kDeeplinkURL)];
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
                [contentController setDeeplinkURL:CTContentStringValue(_content, kDeeplinkURL)];
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
            [contentController setNotificationDeliveryDate:notification.date];
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
                CTContentLogError(@"Product display unavailable, falling back to basic template");
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
        case CTNotificationContentTypeVerticalImage: {
            CTVerticalImageController *contentController = [[CTVerticalImageController alloc] init];
            [self setupContentController:contentController];
        }
            break;
        default:
            CTContentLogError(@"No controller mapped for contentType=%ld, view left empty", (long)self.contentType);
            break;
    }

    if (self.contentViewController == nil) {
        CTContentLogError(@"Controller construction failed, view left empty");
        return;
    }

    self.view.frame = self.contentViewController.view.frame;
    self.preferredContentSize = self.contentViewController.preferredContentSize;
    // A size of zero in either direction means the expanded view has no area on
    // screen. The user then sees an empty space where the template should be.
    if (self.preferredContentSize.width <= 0 || self.preferredContentSize.height <= 0) {
        CTContentLogError(@"Zero preferredContentSize, expanded view will not be visible, controller=%@, size=%@",
                          NSStringFromClass([self.contentViewController class]),
                          NSStringFromCGSize(self.preferredContentSize));
        return;
    }
    CTContentLogInfo(@"Content view ready, controller=%@, size=%@",
                     NSStringFromClass([self.contentViewController class]),
                     NSStringFromCGSize(self.preferredContentSize));
}

- (void)setupContentController:(id)contentController{
    [contentController setData:self.jsonString ?: @""];
    [contentController setTemplateCaption:_notification.request.content.title];
    [contentController setTemplateSubcaption:_notification.request.content.body];
    if (_content[kDeeplinkURL] != nil) {
        [contentController setDeeplinkURL:CTContentStringValue(_content, kDeeplinkURL)];
    }
    [self addChildViewController:contentController];
    [contentController view].frame = self.view.frame;
    [self.view addSubview:[contentController view]];
    self.contentViewController = contentController;
}

- (void)updateContentType:(NSDictionary *)content {
    if (content[kContentSlider] != nil) {
        CTContentLogInfo(@"Resolved template=contentSlider, matched key=%@", kContentSlider);
        self.contentType = CTNotificationContentTypeContentSlider;
        return;
    }

    id templateId = content[kTemplateId];
    if (templateId == nil) {
        if (content[kSingleMediaType] != nil && content[kSingleMediaURL] != nil) {
            CTContentLogInfo(@"Resolved template=singleMedia, matched keys=%@,%@",
                             kSingleMediaType, kSingleMediaURL);
            self.contentType = CTNotificationContentTypeSingleMedia;
        } else {
            CTContentLogError(@"Missing key=%@ and no single media keys, falling back to basic template", kTemplateId);
            self.contentType = CTNotificationContentTypeBasicTemplate;
        }
        return;
    }

    if (![templateId isKindOfClass:[NSString class]]) {
        CTContentLogError(@"Expected NSString for key=%@, got %@, falling back to basic template",
                          kTemplateId, NSStringFromClass([templateId class]));
        self.jsonString = [self createJSONData:content];
        self.contentType = CTNotificationContentTypeBasicTemplate;
        return;
    }

    id json = content[kJSON];
    if (json == nil) {
        CTContentLogInfo(@"Missing key=%@, building json from flat payload keys", kJSON);
        self.jsonString = [self createJSONData:content];
    } else if (![json isKindOfClass:[NSString class]]) {
        CTContentLogError(@"Expected NSString for key=%@, got %@, building json from flat payload keys",
                          kJSON, NSStringFromClass([json class]));
        self.jsonString = [self createJSONData:content];
    } else {
        self.jsonString = json;
    }

    if ([templateId isEqualToString:kTemplateBasic]) {
        self.contentType = CTNotificationContentTypeBasicTemplate;
    } else if ([templateId isEqualToString:kTemplateAutoCarousel]) {
        self.contentType = CTNotificationContentTypeAutoCarousel;
    } else if ([templateId isEqualToString:kTemplateManualCarousel]) {
        self.contentType = CTNotificationContentTypeManualCarousel;
    } else if ([templateId isEqualToString:kTemplateTimer]) {
        self.contentType = CTNotificationContentTypeTimerTemplate;
    } else if ([templateId isEqualToString:kTemplateZeroBezel]) {
        self.contentType = CTNotificationContentTypeZeroBezel;
    } else if ([templateId isEqualToString:kTemplateWebView]) {
        self.contentType = CTNotificationContentTypeWebView;
    } else if ([templateId isEqualToString:kTemplateProductDisplay]) {
        self.contentType = CTNotificationContentTypeProductDisplay;
    } else if ([templateId isEqualToString:kTemplateRating]) {
        self.contentType = CTNotificationContentTypeRating;
    } else if ([templateId isEqualToString:kTemplateVerticalImage]) {
        self.contentType = CTNotificationContentTypeVerticalImage;
    } else {
        // Invalid pt_id value fallback to basic.
        CTContentLogError(@"Unknown pt_id=%@ for this SDK version, falling back to basic template", templateId);
        self.contentType = CTNotificationContentTypeBasicTemplate;
        return;
    }
    CTContentLogInfo(@"Resolved template from pt_id=%@", templateId);
    [CTUtiltiy logPayloadCheckForTemplate:templateId jsonString:self.jsonString ?: @""];
}

- (NSString *)createJSONData:(NSDictionary *)content {
    // create JSON Data from individual keys provided.
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    for (id key in content) {
        if (![key isKindOfClass:[NSString class]]) {
            CTContentLogError(@"Skipping non NSString payload key=%@", key);
            continue;
        }
        id value = content[key];
        // The Swift models declare every field as text. A number is written as
        // text here so the decoder accepts it.
        if ([value isKindOfClass:[NSString class]]) {
            json[key] = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            json[key] = [value stringValue];
        } else {
            CTContentLogError(@"Skipping key=%@, unsupported value type %@",
                              key, NSStringFromClass([value class]));
        }
    }

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (jsonData == nil) {
        CTContentLogError(@"JSON serialization failed, template will render its no data layout, error=%@",
                          error.localizedDescription);
        return @"";
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString == nil) {
        CTContentLogError(@"JSON is not valid UTF-8, template will render its no data layout");
        return @"";
    }
    CTContentLogInfo(@"Built json from %lu payload keys", (unsigned long)json.count);
    return jsonString;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    self.preferredContentSize = self.contentViewController.preferredContentSize;

    // Images arrive after the first layout, so a template can resize itself
    // later. This is the last size the system is told about. The size checked
    // in didReceiveNotification is only the first one.
    if (self.preferredContentSize.width <= 0 || self.preferredContentSize.height <= 0) {
        CTContentLogError(@"Resized to zero preferredContentSize, expanded view will not be visible, controller=%@",
                          NSStringFromClass([self.contentViewController class]));
        return;
    }
    CTContentLogInfo(@"Resized, size=%@", NSStringFromCGSize(self.preferredContentSize));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // The system stops an extension that keeps using memory after this warning.
    // A report that stops right here means the extension was stopped. Large
    // images are the usual cause. The pixel sizes are in the download lines.
    CTContentLogError(@"Memory warning, the system may stop the extension");
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response
                     completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    CTContentLogInfo(@"Received action=%@", response.actionIdentifier);
    if (self.contentViewController == nil) {
        CTContentLogError(@"No controller to handle action=%@, staying open", response.actionIdentifier);
        completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
        return;
    }
    UNNotificationContentExtensionResponseOption actionResponseOption = [self.contentViewController handleAction:response.actionIdentifier];
    CTContentLogInfo(@"Handled action=%@, responseOption=%@", response.actionIdentifier, CTResponseOptionName(actionResponseOption));
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
    if (url == nil) {
        CTContentLogError(@"Nil url, performing notification default action");
        if (@available(iOS 12.0, *)) {
            [self.extensionContext performNotificationDefaultAction];
        }
        return;
    }
    if (self.extensionContext == nil) {
        CTContentLogError(@"Nil extensionContext, cannot open url=%@", url.absoluteString);
        return;
    }

    CTContentLogInfo(@"Opening url=%@", url.absoluteString);
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // IF THE DEEP LINK DIDNT WORK, OPEN PARENT APP
        if (success) {
            CTContentLogInfo(@"Opened url=%@", url.absoluteString);
        } else {
            CTContentLogError(@"openURL failed for url=%@, performing notification default action", url.absoluteString);
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
