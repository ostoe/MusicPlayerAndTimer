//
//  TimerTasks.swift
//  timer
//
//  Created by linhai on 2021/5/31.
//

import Foundation

import UserNotifications
import AudioToolbox

protocol TimerTaskRunPro {
    func runWrapper() -> Result<Any, Error>
//    func resignest() -> Void
}



enum TE {
    case S(String)
    case I(Int)
    case T1((Int, String))
    case T2((Int, String, String))
}


struct STimerTask: Identifiable, TimerTaskRunPro {
    var id : Int
    var title: String
    var display: String
//    var isSelect: Bool
    func runWrapper() -> Result<Any, Error> {
        let params: TE = self.f.0
        let f: (TE)->Void = self.f.1
        
        //run
        f(params)
        return .success(())
    }
    var f: (TE, (TE)->Void)
    
//    init(_ title: String, _ display: String, f: (T, (T)-> Void)) {
//        self.title = title
//        self.display = display
//        self.f = f
//    }
    
}




class CTimerTask: ObservableObject {
    
    
    
    //[(STimerTask, ()->Void)]
    @Published var taskList: [STimerTask] = []
//    STimerTask(title: "alert", display: "alert", f: alert),
    
    @Published var selectIndex: UInt = 0
    
    
    private var notification: MyNotification = MyNotification()
//    let audioManager: AGManager = AGManager(withFileManager: AGFileManager(withFileName: "nnnf"))
    
    init() {
        self.taskList = [STimerTask(id: 0, title: "closeWechatVoiceLine", display: "关闭微信语音通话",  f: (TE.S("s"), self.closeWechatVoiceLine)),
                         STimerTask(id: 1, title: "alert", display: "alert",  f: (TE.I(10), self.alert)),
                         STimerTask(id: 2, title: "notify", display: "notify",  f: (TE.I(10), self.notify))
        ]
//        audioManager.checkRecordPermission()
    }
    
    
    
    func closeWechatVoiceLine(ts: TE) {
        
        print("close wechat")
//        DispatchQueue.global().sync {
//            for _ in 0..<3 {
////                sleep(1)
//                print("closed wechat ")
//
//                let noti = MyNotification()
//                noti.requestNotificationAuthorization()
////                noti.sendNotification()
////                UILocalNotification()
//            let au = AudioAndSpeaker()
//            let time = recorderOne.deviceCurrentTime + 0.01
            
//            let duration: TimeInterval = 10.0
//            let now = Date()
//            let time = now.timeIntervalSinceNow + 0.1
            
//            do {
//                au.audioRecorder.record(atTime: au.audioRecorder.deviceCurrentTime + 0.1, forDuration: duration)
//                au.audioRecorder.record()
//                au.setupRecorder()
//                au.audioRecorder.record(forDuration: 3)
                
//                au.startRecording()
//                sleep(3)
//                au.stopRecording()
//                au.pauseRecording()
                print("audio log ok")
                
                let a = AGAudioRecorder(withFileName: "hello")
//
//                DispatchQueue.global(qos: .userInteractive).async {
                a.doRecord()
//                }
//
////                sleep(3)
////                a.doStopRecording()
//                print("new record over")
                sleep(5)
//                print("stop")
                    a.doStopRecording()

//                self.audioManager.recordStart()
                print("log beagin")
//                sleep(5)
//                self.audioManager.stopRecording()
//                a.doPlay()
//                sleep(1)
                print("play over")
//            } catch let error  {
//                print("recorder error: \(error.localizedDescription)")
//            }
//
            
//        }
        
        
    }
    
    
    func alert(i: TE ) {
            print("alert process")
        self.notification.sendNotification("标题：🌸🌸🌸", "吃饭啦～", "abcfdsd")
        self.notification.sendNotification("标题：🌸🌸🌸", "吃饭啦～", "abcfdsd")
//        let serial = DispatchQueue(label: "serial",attributes: .init(rawValue:0))
//
//        DispatchQueue.main.async {
////        serial.async {
//
////            self.notification.requestNotificationAuthorization()
//            for i in 0...2 {
////                sleep(1)
//                if i % 2 == 0 {
//
//                    self.notification.sendNotification("通知----\(i)", "--\(i)--", "abcfdsd")
//
//                } else {
//
//                    self.notification.sendNotification("通知----\(i)", "--\(i)", "tyuioio")
//
//                }
//            }
//        }
//            self.notification.sendNotification()
//                UILocalNotification()
//        }
//        switch i {
//        case .I(let value): do {
//            print(value)
//        }
//        default:
//            print(10)
//        }
        
    }
    
    func notify(i: TE ) {
        
        switch i {
        case .I(let value): do {
            print(value)
        }
        default:
            print(10)
        }
        
    }
    
    func testRun() {
       _ = self.taskList[0].runWrapper()
//        self.taskList[1].
    }
    
}




