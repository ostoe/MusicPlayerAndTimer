//
//  ViewController.swift
//  timer
//
//  Created by linhai on 2021/6/2.
//

import Foundation
import UserNotifications
import UIKit


class MyNotification {
    
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    private var badgeNumber: UInt = 0
    private var lastUUID: String = UUID().uuidString
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.userNotificationCenter.delegate = self
//        
//        self.requestNotificationAuthorization()
//        self.sendNotification()
//    }
    
    
    // request access notification
    
    
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: [.alert, .badge, .sound, .announcement])
        self.userNotificationCenter.requestAuthorization(options: authOptions, completionHandler: {
            (success, error) in
            if let error = error {
                print("auth notification error: \(error)...")
            } else {
                print("auth notification success: \(success)...")
            }
        } )
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotificationAuthorization()
            case .authorized, .provisional:
                self.sendNotification("a")
            default:
                break // Do nothing
            }
        }
    }
    
    
    
    func sendNotification(_ title: String,
                          _ body: String = "default body" ,
                          _ groupIdentifier: String = "abcd5678998765",
                          _ timeInterval: Double = 0.01,
                          _ sound: UNNotificationSound = .default) {
        
        let notificationContent = UNMutableNotificationContent()
        
        // title
        notificationContent.title = title
        
        // body
        if body != "default body" {
            notificationContent.body = body
        }
        

//        notificationContent.identi
        // badge 角标 这里是添加到全局队列中的request，还未发送的，不是已推送个数。
        self.userNotificationCenter.getPendingNotificationRequests(completionHandler: { notis in   self.badgeNumber = UInt(notis.count) })
        print("ntnb: \(self.badgeNumber)")
        notificationContent.badge = NSNumber(value: self.badgeNumber + 1)
        // userinfo
        notificationContent.userInfo = ["customParameterKey_from": "Sergey"]
//            NSNumber(value: 3)
        // Attachment
        if let url = Bundle.main.url(forResource: "dune", withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                                    url: url,
                                                                    options: nil) {
                    notificationContent.attachments = [attachment]
                }
        }
        
//        UNNotificationAttachment(identifier: <#T##String#>, url: <#T##URL#>, options: <#T##[AnyHashable : Any]?#>)
//
        // sound
        notificationContent.sound = sound
        
        // threadIdentifier
        notificationContent.threadIdentifier =  groupIdentifier
        print(notificationContent.threadIdentifier)
        
//        if categoryIdentifier != "abcd5678998765" {
//            notificationContent.categoryIdentifier = categoryIdentifier
//        }
        
        // 分组后会显示来自xxxx的通知
        notificationContent.summaryArgument = groupIdentifier
        
        var now = Date()
        print("now: \(now)")
        let calendar = Calendar.current
        
//        now.addTimeInterval(Double.random(in: 3..<15))
        now.addTimeInterval(0.1)
        // TimeZone.init(secondsFromGMT: 3600*7)!
        let dateComponets1 = calendar.dateComponents(in: TimeZone.current, from: now)
        //输出结果（通过DateComponents对象点出对应的时间成分）
        print("\(dateComponets1.year!)-\(dateComponets1.month!)-\(dateComponets1.day!) \(dateComponets1.hour!):\(dateComponets1.minute!)")
        //使用另一个重载函数进行转换（第一个参数给一个Set对象，给了哪些时间成分对象就可以在后面得到对应的成分）
        
        let dateComponets2 = calendar.dateComponents([Calendar.Component.year,
                                                      Calendar.Component.month,
                                                      Calendar.Component.day,
                                                      Calendar.Component.hour,
                                                      Calendar.Component.minute,
                                                      Calendar.Component.second,
        ], from: now)
        print("\(dateComponets2.year!)-\(dateComponets2.month!)-\(dateComponets2.day!)")
        
//        let cTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponets2, repeats: false)
        //timeInterval
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        //这里的identifier必须唯一才能不被替换，然后再使用threadIdentifier和summaryArgument去匹配分组和分组名：
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: trigger)
        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [self.lastUUID])
        
//        self.userNotificationCenter.
        self.lastUUID = uuid
        self.userNotificationCenter.add(request, withCompletionHandler: {
            (error) in
            if let error = error {
                print("request error: \(error)")
                return
            }
        })
    }
}
