#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#if __has_include(<CleverTapSDK/CleverTap.h>)
#import <CleverTapSDK/CleverTap.h>
#else
#import "CleverTap.h"
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [CleverTap autoIntegrate];
    [self registerPush];
    
    
//  for running notification in foreground
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)registerPush {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action_1" title:@"Back" options:UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action_2" title:@"Next" options:UNNotificationActionOptionNone];
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action_3" title:@"View In App" options:UNNotificationActionOptionNone];
    UNNotificationCategory *cat = [UNNotificationCategory categoryWithIdentifier:@"CTNotification" actions:@[action1, action2, action3] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    [center setNotificationCategories:[NSSet setWithObjects:cat, nil]];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if( !error ){
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"APPDELEGATE: didReceiveRemoteNotification %@", userInfo);
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    NSLog(@"APPDELEGATE: open url %@", url);
    return YES;
}

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options
completionHandler:(void (^ __nullable)(BOOL success))completion {
    NSLog(@"APPDELEGATE: openURL:options:completionHandler %@", url);
    if (completion) {
        completion(YES);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
