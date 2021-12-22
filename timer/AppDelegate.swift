//
//  AppDelegate.swift
//  timer
//
//  Created by linhai on 2021/5/17.
//

import UIKit
import CoreData
//import UserNotifications
import AVFoundation
import SwiftUI


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        Thread.sleep(forTimeInterval: )
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .announcement, .sound], completionHandler: {(success, error) in
            print("通知授权" + (success ? "成功" : "失败"));
        })
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("\(settings.authorizationStatus)")
            if settings.alertSetting == .enabled {

                print("notification is enabled")
                
                //alert is enabled
            } else {
                print("notification status: \(settings.alertSetting)")
            }
//            UNNotificationRequest(coder: .)

        }
        UNUserNotificationCenter.current().getPendingNotificationRequests {  notifications
            
        in
            for notification in notifications {
                        print(notification)
                    }
        }
        do {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay, .defaultToSpeaker])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        return true
    }
    
    
    // Local notifications
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("[nitification]Received notification with ID = \(id)")

        completionHandler([.sound, .badge, .list, .banner])
    }
    

    // 点击横幅⌚️事件 或者点击后主界面打开
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.identifier
        print("[response]Received notification with ID = \(id)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }

    
        
    
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "timer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}



//extension AppDelegate: UNUserNotificationCenterDelegate
//{
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
//    {
//        UNUserNotificationCenter.current().delegate = self
//
//        return true
//    }
//}
