//
//  AudioAndSpeaker.swift
//  timer
//
//  Created by linhai on 2021/6/4.
//

import Foundation
import AVFoundation
import UIKit

class AudioAndSpeaker: NSObject, AVAudioRecorderDelegate {
    
//    var audioStatus:  = AudioStatus.Stopped
    var audioRecorder: AVAudioRecorder!
//    var a = AVAudioEngine()
    override init() {
        super.init()
        
    }
    

    
    func setupRecorder() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.mixWithOthers, .allowAirPlay, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            
            session.requestRecordPermission({res in
                print("麦克风授权" + (res ? "成功" : "失败"));
            })
        } catch let error as NSError {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
        
        let recordSettings: [String : Any] = [
                    AVFormatIDKey: kAudioFormatAppleLossless,
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderBitRateKey: 320000,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
        let fileName = "audioFile.m4a"
//        let fileUrl = URL(fileURLWithPath: fileName)
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
//        let audioFilename = paths.appendingPathComponent(fileName)

        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName)
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSettings)
            self.audioRecorder.delegate = self
            self.audioRecorder.prepareToRecord()
            
            
        } catch let error  {
            print("recorder error: \(error)")
        }
        
    }
    
    
    // 开始录音
    func startRecording() {
//         startUpdateLoop()
         // 追踪，记录下当前 app 的录音状态
//         audioStatus = .recording
         // 这一行，就是开始录音了
        self.setupRecorder()
        self.audioRecorder.record()
     }
    
    // 停止录音
     func stopRecording() {
//          recordButton.setBackgroundImage(UIImage(named: "button-record"), for: UIControl.State.normal  )
//          audioStatus = .stopped
        self.audioRecorder.stop()
//        self.audioRecorder = nil
//          stopUpdateLoop()
      }
    
    func pauseRecording() {
        self.audioRecorder.pause()
    }
    
    
}
