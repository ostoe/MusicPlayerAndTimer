//
//  AGAudioRecorder.swift
//  BaseProject
//
//  Created by AshvinGudaliya on 17/09/18.
//  Copyright © 2018 AshvinGudaliya. All rights reserved.
//

import UIKit
import AVFoundation
import AudioUnit

enum AGAudioRecorderState {
    case Pause
    case Play
    case Finish
    case Failed(String)
    case Recording
    case Ready
    case error(Error)
}

protocol AGAudioRecorderDelegate {
 
    func agAudioRecorder(_ recorder: AGAudioRecorder, withStates state: AGAudioRecorderState)
    func agAudioRecorder(_ recorder: AGAudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String)
}

class AGAudioRecorder: NSObject {

    private var isAudioRecordingGranted: Bool = false
    private var filename: String = ""
    
    private var recorderState: AGAudioRecorderState = .Ready {
        willSet{
            delegate?.agAudioRecorder(self, withStates: newValue)
        }
    }
    
    
    private var audioRecorder: AVAudioRecorder! = nil
    private var audioPlayer: AVAudioPlayer! = nil
    private var meterTimer: Timer! = nil
    private var currentTimeInterval: TimeInterval = 0.0
    
    var delegate: AGAudioRecorderDelegate?
    
    init(withFileName filename: String) {
        super.init()
        
        self.recorderState = .Ready
        self.filename = filename
        self.check_record_permission()
    }
    
    func aaa()  {
//        let a = AVCaptureAudioDataOutput()
        var acdes = AudioComponentDescription(componentType: .zero, componentSubType: .zero, componentManufacturer: .zero, componentFlags: 0, componentFlagsMask: 0)
        if let component = AudioComponentFindNext(nil, &acdes) {
            var audioUnit: AudioComponentInstance? = nil
            AudioComponentInstanceNew(component, &audioUnit)
            var enable: UInt32 = 0
            AudioUnitSetProperty(audioUnit!, .zero, .zero, 1, &enable, UInt32(MemoryLayout<UInt32>.size))
        }
        
       
        
        
    }
    
 
    
    private func check_record_permission() {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        @unknown default:
            fatalError()
        }
    }
    
    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func fileUrl() -> URL {
        let filename = "\(self.filename).m4a"
        let filePath = documentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func changeFile(withFileName filename: String) {
        self.filename = filename
        
        if audioPlayer != nil {
            doPause()
        }
        
        if audioRecorder != nil {
            doStopRecording()
            setupRecorder()
        }
    }
    
    private func setupRecorder() {
        
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .voiceChat   ,options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: fileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                self.recorderState = .Ready
            }
            catch let error {
                recorderState = .error(error)
            }
        }
        else {
            recorderState = .Failed("Don't have access to use your microphone.")
        }
    }
    
    @objc private func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            currentTimeInterval = currentTimeInterval + 0.01
            let hr = Int((currentTimeInterval / 60) / 60)
            let min = Int(currentTimeInterval / 60)
            let sec = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            delegate?.agAudioRecorder(self, currentTime: currentTimeInterval, formattedString: totalTimeString)
            audioRecorder.updateMeters()
        }
    }
    
    private func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder?.stop()
            meterTimer?.invalidate()
            recorderState = .Finish
        }
        else {
            recorderState = .Failed("Recording failed.")
        }
    }
    
    private func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            recorderState = .Ready
            print("player init ok.")
        }
        catch {
            recorderState = .error(error)
            debugPrint(error)
        }
    }
    
    func doRecord() {
        aaa()
        if audioRecorder == nil {
            setupRecorder()
        }
        
        if audioRecorder.isRecording {
            doStopRecording()
        }
        else {
            audioRecorder.record()
//            sleep(10)
            currentTimeInterval = 0.0
//            meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recorderState = .Recording
        }
    }
    
    func doStopRecording() {
        
        guard audioRecorder != nil else {
            return
        }
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            finishAudioRecording(success: true)
        } catch {
            recorderState = .error(error)
        }
    }
    
    func doPlay() {
        if audioPlayer == nil {
            self.preparePlay()
        }
        
        if audioRecorder != nil, audioRecorder.isRecording {
            self.doStopRecording()
        }
        
        if audioPlayer.isPlaying {
            doPause()
        }
        else{
            if FileManager.default.fileExists(atPath: fileUrl().path) {
                preparePlay()
                audioPlayer.play()
                recorderState = .Play
            }
            else {
                recorderState = .Failed("Audio file is missing.")
            }
        }
    }
    
    func doPause() {
        
        guard audioPlayer != nil else {
            return
        }
        
        if audioRecorder != nil, audioRecorder.isRecording {
            self.doStopRecording()
        }
        
        if (audioPlayer.isPlaying){
            audioPlayer.pause()
        }
        recorderState = .Pause
    }
}

extension AGAudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }
}
