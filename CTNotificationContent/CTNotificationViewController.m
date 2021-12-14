#import "CTNotificationViewController.h"
#import "BaseCTNotificationContentViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "CTContentSliderController.h"
#import "CTContentSimpleViewController.h"

@interface CTNotificationViewController () <UNNotificationContentExtension>

@property(nonatomic, strong, readwrite) BaseCTNotificationContentViewController *contentViewController;

@end

@implementation CTNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    BaseCTNotificationContentViewController *contentController;
    
    switch (self.contentType) {
        case CTNotificationContentTypeContentSlider:
            contentController = [[CTContentSliderController alloc] init];
            break;
        case CTNotificationContentTypeContentSimple:
            contentController = [[CTContentSimpleViewController alloc] init];
        default:
            break;
    }
    
    if (contentController != nil) {
        [self displayContentController:contentController];
    }
}

- (void)didReceiveNotification:(UNNotification *)notification {
    [self.contentViewController configureViewForContent:notification.request.content];
    self.view.frame = self.contentViewController.view.frame;
    self.preferredContentSize = self.contentViewController.preferredContentSize;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response
                     completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    UNNotificationContentExtensionResponseOption actionResponseOption = [self.contentViewController handleAction:response.actionIdentifier];
    [self userDidReceiveNotificationResponse:response];
    completion(actionResponseOption);
}

- (void)displayContentController: (BaseCTNotificationContentViewController *) contentController {
    if (self.contentViewController != nil) {
        return;
    }
    [self addChildViewController:contentController];
    contentController.view.frame = self.view.frame;
    if (self.contentType == CTNotificationContentTypeContentSimple) {
        contentController.view.backgroundColor = UIColor.redColor;
    } else {
        contentController.view.backgroundColor = UIColor.yellowColor;
    }
    [self.view addSubview:contentController.view];
    [contentController didMoveToParentViewController:self];
    self.contentViewController = contentController;
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

- (void)recordEventAPIWithData:(NSDictionary *)pushData withHeader:(NSArray *)header {
    //    CTDeviceInfo *deviceInfo = CTDeviceInfo.
    NSString *endpoint = pushData[@"api"];
    //https://wzrkt.com/a1?os=iOS&z=TEST-Z9R-486-4W5Z//&t=30905&ts=1639395864
    //self.deviceInfo.sdkVersion
    int currentRequestTimestamp = (int) [[[NSDate alloc] init] timeIntervalSince1970];
    endpoint = [endpoint stringByAppendingFormat:@"&ts=%d", currentRequestTimestamp];
    
    NSString *sdkVersion = pushData[@"WR_SDK_REVISION"];
    endpoint = [endpoint stringByAppendingFormat:@"&t=%@", sdkVersion];
    
    
//    NSBundle *bundle = [NSBundle mainBundle];
//    if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
//        // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
//        bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
//    }
//
//    NSString *appDisplayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    @try {
        NSString *jsonBody = [self jsonObjectToString:header];
        NSMutableURLRequest *request = [self createURLRequestFromURL:[[NSURL alloc] initWithString:endpoint] withData:pushData];
        request.HTTPBody = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
        
        __block BOOL success = NO;
        __block NSData *responseData;
        
        __block BOOL redirect = NO;
        
        // Need to simulate a synchronous request
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        //set this session part once
        NSURLSessionConfiguration *sc = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sc setHTTPAdditionalHeaders:@{
            @"Content-Type" : @"application/json; charset=utf-8"
        }];
        
        sc.timeoutIntervalForRequest = 10;
        sc.timeoutIntervalForResource = 10;
        [sc setHTTPShouldSetCookies:NO];
        [sc setRequestCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sc];
        NSURLSessionDataTask *postDataTask = [urlSession
                                              dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            responseData = data;
            
            if (error) {
//                CleverTapLogDebug(@"Content Extension logs", @"Network error while sending queue, will retry: %@", error.localizedDescription);
            }
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                
                success = (httpResponse.statusCode == 200);
                
                if (success) {
                    NSLog(@"Event recorded success");
                    //                    redirect = [self updateStateFromResponseHeadersShouldRedirect: httpResponse.allHeaderFields];
                    
                } else {
                    //                    CleverTapLogDebug(self.config.logLevel, @"%@: Got %lu response when sending queue, will retry", self, (long)httpResponse.statusCode);
                }
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
        [postDataTask resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (!success) {
            //            [self scheduleQueueFlush];
            //            [self handleSendQueueFail];
        }
        
        if (!success || redirect) {
            // error so return without removing events from the queue or parsing the response
            // Note: in an APP Extension we don't persist any unsent queues
            return;
        }
        
        //        [queue removeObjectsInArray:batch];
        
        //        [self parseResponse:responseData];
        
        //        CleverTapLogDebug(self.config.logLevel,@"%@: Successfully sent %lu events", self, (unsigned long)[batch count]);
        
    } @catch (NSException *e) {
        //        CleverTapLogDebug(self.config.logLevel, @"%@: An error occurred while sending the queue: %@", self, e.debugDescription);
    }
}

- (NSMutableURLRequest *)createURLRequestFromURL:(NSURL *)url withData:(NSDictionary *)pushData{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *accountId = pushData[@"accountId"];
    NSString *accountToken = pushData[@"accountToken"];
    if (accountId) {
        [request setValue:accountId forHTTPHeaderField:@"X-CleverTap-Account-Id"];
    }
    if (accountToken) {
        [request setValue:accountToken forHTTPHeaderField:@"X-CleverTap-Token"];
    }
    return request;
}

- (NSString *)jsonObjectToString:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:0
                                                             error:&error];
        if (error) {
            return @"";
        }
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    @catch (NSException *exception) {
        return @"";
    }
}

- (void)sendQueue:(NSMutableArray *)queue {
    // no state maintained -> config, muted
    //how to decide upon logs????
}
@end
