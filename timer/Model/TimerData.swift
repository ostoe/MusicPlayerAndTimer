//
//  TimerData.swift
//  timer
//
//  Created by linhai on 2021/5/22.
//

import Foundation
import UIKit

struct TimeUnit {
    var timeUnit: Double
    var maxLimite: Int
    
}

enum ToggleState {
    case Running
    case Pause
}

class TimerData: ObservableObject {
    

//    var minutesDefault: String
//    @Published var minutes: String = "45"
    @Published var minutes: TimeUnit
    @Published var hours: TimeUnit
    @Published var seconds: TimeUnit
    
    var count: UInt = 0
    var timer: DispatchSourceTimer?
    var limitTime = 10
    var savedTimeTuple: (Double, Double, Double, UInt) = (0, 0, 0, 0)
    var toggleState: ToggleState = ToggleState.Pause
    var milliSeconds: UInt = 0
    var totalMilliSeconds: UInt = 0
    // first time to running, not equal to totalMilliSeconds
    var savedMilliSeconds: UInt = 0
    @Published var toggleButtonState: String = "play.fill"
    
    var tasksRunInstance: CTimerTask
    
    
    init(_ defaultHour: Double, _ defaultMinute: Double, _ defaultSecond: Double, _ tri: CTimerTask) {
        self.minutes = TimeUnit(timeUnit: defaultMinute, maxLimite: 60)
        self.hours = TimeUnit(timeUnit: defaultHour, maxLimite: 24)
        self.seconds = TimeUnit(timeUnit: defaultSecond, maxLimite: 60)
//        self.timer? = nil
//            DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        self.tasksRunInstance = tri
    }
    
    func toggle() {
        if toggleState == .Running {
            
            self.pause()
            
            print("l 56")
        } else if toggleState == .Pause {
            
            self.run()
        } else {
            
        }
    }
    
    
    func run() {
        self.toggleButtonState = "stop.fill"
        self.toggleState = .Running
        if self.hours.timeUnit == 0 && self.seconds.timeUnit == 0 && floor(self.minutes.timeUnit) == 0 {
            self.toggleButtonState = "play.fill"
            self.toggleState = .Pause
            return
        }
//        print(self.hours.timeUnit , self.minutes.timeUnit ,self.seconds.timeUnit )
        let fh: Double = floor(self.hours.timeUnit)
        let fm: Double = floor(self.minutes.timeUnit)
        let fs: Double = floor(self.seconds.timeUnit)
        
        self.totalMilliSeconds =  UInt(fh * 36000 + fm * 600 + fs * 10)  + self.milliSeconds
        
//        self.totalMilliSeconds = UInt(floor(self.hours.timeUnit)  + floor(self.minutes.timeUnit)  + floor(self.seconds.timeUnit) * 10 )
//            UInt(floor(self.hours.timeUnit) *  36000
//                                        + floor(self.minutes.timeUnit) * 600
//                                        + floor(self.seconds.timeUnit) * 10) + self.milliSeconds
        print(self.totalMilliSeconds, self.savedMilliSeconds)
        if self.totalMilliSeconds != self.savedMilliSeconds {
            if self.timer != nil && !self.timer!.isCancelled {
                self.timer!.resume()
                self.timer!.cancel()
                print("timers canceled..")
            }
            self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            self.timer!.schedule(deadline: .now(), repeating: .milliseconds(100))
            self.timer!.setEventHandler(handler: self.runhandler)
            self.totalMilliSeconds += 1
        }
        print("resume..")
        self.timer!.resume()
    }
    
    func pause() {
        print("pause")
        self.toggleState = .Pause
        self.toggleButtonState = "play.fill"
        self.timer!.suspend()
        self.savedMilliSeconds = self.totalMilliSeconds
        if self.totalMilliSeconds == 0 {
            self.timer!.resume()
            self.timer!.cancel()
            print("run real func")
            let stk: STimerTask = self.tasksRunInstance.taskList[Int(self.tasksRunInstance.selectIndex)]
            DispatchQueue.global(qos: .userInteractive).async { /*[weak self] in*/
                let _ = stk.runWrapper()
            }
            // todo update view
        }
    }
    
    
    // handle
    func runhandler () {
//        print("i")
        DispatchQueue.main.async {
            self.totalMilliSeconds -= 1
            
            self.hours.timeUnit = (Double(self.totalMilliSeconds) / 36000)
            self.minutes.timeUnit = (Double(self.totalMilliSeconds).truncatingRemainder(dividingBy: 36000) / 600)
            self.seconds.timeUnit = (Double(self.totalMilliSeconds).truncatingRemainder(dividingBy: 600) / 10)
            self.milliSeconds = UInt(Double(self.totalMilliSeconds).truncatingRemainder(dividingBy: 10))
//            print("trunck mill: \(self.milliSeconds)   \(self.totalMilliSeconds)")
            if self.totalMilliSeconds == 0 {
                self.pause()
                self.milliSeconds = 0
                // TODO update view
            }
//
        }
    }
//
//    func run() {
//
//        if self.hours.timeUnit == 0 && self.seconds.timeUnit == 0 && self.minutes.timeUnit == 0 {
//            return
//        }
//
//        if savedTimeTuple.0 != self.hours.timeUnit || savedTimeTuple.1 != self.seconds.timeUnit || savedTimeTuple.2 != self.hours.timeUnit {
//            if self.timer.isCancelled {
//            } else {
//                self.timer.cancel()
//            }
//            self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
//            self.timer.schedule(deadline: .now(), repeating: .milliseconds(100))
//            self.count = 0
//        } else {
//            self.timer.resume()
//        }
//
////        sleep(10)
////        self.timer.resume()
//    }
//
//    func pause() {
//        self.savedTimeTuple = (self.hours.timeUnit, self.minutes.timeUnit, self.seconds.timeUnit, self.count)
//        self.timer.suspend()
//    }
//
//
//
//    func runFunc() {
//
//        DispatchQueue.global().async {
//            self.updateMilliseconds()
//            self.count += 1
//            if self.count % 10 == 0 {
//                self.updateSeconds()
//                self.updateMinutes()
//                if self.count % 600 == 0 {
//
//                }
//                if self.count % 36000 == 0 {
//                    self.updateHours()
//                }
//
//                // 是否归零
//                if self.hours.timeUnit == 0 && roundl(self.minutes.timeUnit) == 0 && self.seconds.timeUnit == 0 {
//                    self.count = 0
//                    self.pause()
//                }
//            }
//            print("async: \(( 10 -  self.count))")
//        }
//
//    }
//
//    func updateHours() {
//        self.hours.timeUnit -= 1
//    }
//
//    func updateMinutes() {
//        if self.minutes.timeUnit == 0
//        self.minutes.timeUnit -= 1/60
//    }
//
//    func updateSeconds() {
//        if self.seconds.timeUnit != 0 {
//            self.seconds.timeUnit -= 0.1
//            self.updateMinutes()
//        } else {
//            self.seconds.timeUnit = 59
//        }
//
//    }
//
//    func updateMilliseconds() {
//        if self.milliSeconds != 0 {
//            self.milliSeconds -= 1
//            self.updateSeconds()
//        }  else if self.hours.timeUnit == 0 && roundl(self.minutes.timeUnit) == 0 && self.seconds.timeUnit == 0 {
//            self.timer.cancel()
//        } else {
//            self.milliSeconds = 9
//        }
//    }
}
