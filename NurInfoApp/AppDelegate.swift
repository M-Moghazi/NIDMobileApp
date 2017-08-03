//
//  AppDelegate.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/15/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Parse configuration in Heroku
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            ParseMutableClientConfiguration.applicationId = "NursingInformaticsMobileApp"
            ParseMutableClientConfiguration.clientKey = "NursingInformaticsMasterKey"
            ParseMutableClientConfiguration.server = "http://nidmobileapp.herokuapp.com/parse"
        }
        Parse.initialize(with: parseConfig)
        
        logIn()
        
        //change tab bar color
        UITabBar.appearance().tintColor = UIColor(colorLiteralRed: 0/255, green: 121/255, blue: 193/255, alpha: 1)
        UITabBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(colorLiteralRed: 0/255, green: 121/255, blue: 193/255, alpha: 1)
        UINavigationBar.appearance().isTranslucent = true
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
            print("permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification Settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { (data) -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
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
    //login in user defaults
    func logIn() {
        
        let username: String? = UserDefaults.standard.string(forKey: "username")
        
        if username != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mytabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            window?.rootViewController = mytabBar
        }
    }

}

