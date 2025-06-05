import UIKit
import UserNotifications
import CleverTapSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue + 1)
        CleverTap.autoIntegrate()
        // register for push notifications
        self.registerPush()
//        for running notification in foreground
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
//    for running notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            print("Push notification received in foreground.")
            completionHandler([.alert, .badge, .sound])
        }
    
    private func registerPush() {
        
        // register category with actions
        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "Open deeplink", options: [])
        let category = UNNotificationCategory(identifier: "CTNotification", actions: [action1, action2, action3], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // request permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
            (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("APPDELEGATE: open url \(url)")
        DispatchQueue.main.async {
            self.showAlert(message: "APPDELEGATE: open url \(url)")
        }
        return true
    }
    
    func open(_ url: URL, options: [String : Any] = [:],
              completionHandler completion: ((Bool) -> Swift.Void)? = nil){
        print("APPDELEGATE: open url \(url) with completionHandler")
        DispatchQueue.main.async {
            self.showAlert(message: "APPDELEGATE: open url \(url) with completionHandler")
        }
        
        completion?(false)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("did receive remote notification \(userInfo)")
    }
    
    func showAlert(message:String) {
        let alertController = UIAlertController(title: "Deeplink", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

