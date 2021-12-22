//
//  PlayerViewModel.swift
//  timer
//
//  Created by linhai on 2021/6/9.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftUIX
import SwiftUI


struct PlaybackValue {
    var value: Double
    var label: String
    var id: String {
        return "\(label)-\(value)"
    }
}

enum PlayControl {
    case current
    case next
    case previous
}


class EQfrequency: ObservableObject {
    @Published var a: Float = 0
    //    @Published var fl: [(Int, Float)]
    init () {
        //        [60,170,310,600,1000,3000,6000,12000,14000,16000]
        //        fl = [(60, a)]
    }
}


class AVEnginePlayerModel: NSObject, ObservableObject {
    
    // public var
    //    DirectorThreadSafeClosure
    
    @Published var isPlaying = false
    @Published var isPlayerReady = false
    
    @Published var playbackRateIndex: Int = 2 {
        didSet {
            // todo
            if let a = SAPlayer.shared.audioModifiers[0] as? AVAudioUnitTimePitch {
                a.rate = Float(allPlaybackRates[playbackRateIndex].value)
            }
            //            timeEffect.rate = Float(allPlaybackRates[playbackRateIndex].value)
        }
    }
    
    // 也许加了均衡器以后这个就失效了
    @Published var playbackPitchIndex: Int = 1 {
        didSet {
            if let a = SAPlayer.shared.audioModifiers[0] as? AVAudioUnitTimePitch {
                a.pitch = 1200 * Float(allPlaybackPitches[playbackPitchIndex].value)
            }
            //            timeEffect.pitch = 1200 * Float(allPlaybackPitches[playbackPitchIndex].value)
        }
    }
    
    @Published var reVerbEffectSlider: Double = 0 {
        didSet {
            guard reVerbEffectSlider != oldValue else {return}
            setAudioUnitReverbWet(preset: Float(reVerbEffectSlider))
        }
    }
    
    
    
    @Published var playProgress: Double = 0 {
        didSet {
            //            seek(to: offsetTime)
        }
    }
    
    @Published var playerTime: String = "0"
    @Published var totalTime: String = "0"
    @Published var meterLevel: Float = 0
    @Published var waveGraphData: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
    
    @Published var eqfrequency: [Int]  = [60,170,310,600,1000,3000,6000,12000,14000,16000]
    
    var downloadId: UInt?
    var durationId: UInt?
    var bufferId: UInt?
    var playingStatusId: UInt?
    var queueId: UInt?
    var elapsedId: UInt?
    
    var duration: Double = 0.0
    var playbackStatus: SAPlayingStatus = .paused
    
    var musicItemController: MusicItemPlayerController? = nil
    
    @Published var downloadProgress: Double = 0
    @Published var bufferedProgress: Double = 0
    @Published var isDownloading: Bool = false
    @Published var isPlayable: Bool = false
    let allPlaybackRates: [PlaybackValue] = [
        .init(value: 0.25, label: "0.25x"),
        .init(value: 0.5, label: "0.5x"),
        .init(value: 1, label: "1x"),
        .init(value: 1.25, label: "1.25x"),
        .init(value: 2, label: "2x"),
        .init(value: 4, label: "4x")
    ]
    
    var allPlaybackPitches: [PlaybackValue] = [
        .init(value: -0.5, label: "-½"),
        .init(value: 0, label: "0"),
        .init(value: 0.5, label: "+½")
    ]
    
    // private var
    //    private var engine = AVAudioEngine()
    //    private var player = AVAudioPlayerNode()
    
    //    private var timeEffect = AVAudioUnitTimePitch()
    
    
    
    // public method
    
    override init() {
        super.init()
    }
    
    convenience init(_ musicItemController: MusicItemPlayerController) {
        self.init()
        self.musicItemController = musicItemController
        //        setupAudio()
        //        setupDisplink()
        addRandomModifiers()
        subscribeToChanges()
        let currentItem = musicItemController.currentPlay
        SAPlayer.shared.startSavedAudio(withSavedUrl: currentItem!.url,
                                        mediaInfo: currentItem?.mediaInfo )
        
    }
    
    func addRandomModifiers() {
        let node = AVAudioUnitReverb()
        node.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
        SAPlayer.shared.audioModifiers.append(node)
        node.wetDryMix = 0
        reVerbEffectSlider = 0
        let frequency:[Int] = self.eqfrequency
        let node2 = AVAudioUnitEQ(numberOfBands:frequency.count)
        node2.globalGain = 1
        for i in 0...(node2.bands.count-1) {
            node2.bands[i].frequency  = Float(frequency[i])
            node2.bands[i].gain       = 0
            node2.bands[i].bypass     = true
            node2.bands[i].filterType = .parametric
        }
        SAPlayer.shared.audioModifiers.append(node2)
        //        SAPlayer.shared.audioModifiers.append(timeEffect)
    }
    
    func setAudioUnitReverbType(preset: AVAudioUnitReverbPreset) {
        if let a = SAPlayer.shared.audioModifiers[1] as? AVAudioUnitReverb {
            //            SAPlayer.shared.playerNode?.pause()
            //            SAPlayer.shared.engine?.pause()
            a.loadFactoryPreset(preset)
            
            //            do {
            //                try SAPlayer.shared.engine?.start()
            //
            //            } catch let error {
            //                Log.monitor(error.localizedDescription)
            //            }
            //            SAPlayer.shared.playerNode?.play()
        }
    }
    
    func setAudioUnitReverbWet(preset: Float) {
        if let a = SAPlayer.shared.audioModifiers[1] as? AVAudioUnitReverb {
            //            SAPlayer.shared.playerNode?.pause()
            //            SAPlayer.shared.engine?.pause()
            a.wetDryMix = preset * 100
            //            do {
            //                try SAPlayer.shared.engine?.start()
            //
            //            } catch let error {
            //                Log.monitor(error.localizedDescription)
            //            }
            //            SAPlayer.shared.playerNode?.play()
            
        }
    }
    func getAudioUnitReverbWet() -> Float {
        if let a = SAPlayer.shared.audioModifiers[0] as? AVAudioUnitReverb {
            return a.wetDryMix
        } else { return 0 }
    }
    
    
    
    func subscribeToChanges() {
        playingStatusId = SAPlayer.Updates.PlayingStatus.subscribe { [weak self] (url, playing) in
            guard let self = self else { return }
            guard self.getFileUrl() != nil else { return }
            self.playbackStatus = playing
            switch playing {
            case .playing:
                self.isPlaying = true
                return
            case .paused:
                self.isPlaying = false
                return
            case .buffering:
                self.isPlaying = false
                return
            case .ended:
                self.isPlaying = false
                return
            }
        }
        
        durationId = SAPlayer.Updates.Duration.subscribe { [weak self] (url, duration) in
            guard let self = self else { return }
            guard self.getFileUrl() != nil else { return }
            self.totalTime = SAPlayer.prettifyTimestamp(duration)
            self.duration = duration
        }
        
        elapsedId = SAPlayer.Updates.ElapsedTime.subscribe { [weak self] (url, position) in
            guard let self = self else { return }
            guard self.getFileUrl() != nil else { return }
            DispatchQueue.main.async {
                self.playerTime = SAPlayer.prettifyTimestamp(position)
                
                guard self.duration != 0 else { return }
                
                self.playProgress = Double(position/self.duration)
            }
        }
        
        downloadId = SAPlayer.Updates.AudioDownloading.subscribe { [weak self] (url, progress) in
            guard let self = self else { return }
            if self.isDownloading {
                DispatchQueue.main.async {
//                    print("down progress \(progress) \(self.isDownloading)")
//                    UIView.performWithoutAnimation {
                        self.downloadProgress = progress
//                    }
                }
            }
        }
        
        bufferId = SAPlayer.Updates.StreamingBuffer.subscribe{ [weak self] (url, buffer) in
            guard let self = self else { return }
//            guard url == self.selectedAudio.savedUrl || url == self.selectedAudio.url else { return }
            if self.duration == 0.0 { return }
            print("\(buffer.bufferingProgress)")
            self.bufferedProgress = buffer.bufferingProgress
//            if buffer.bufferingProgress >= 0.99 {
//                self.streamButton.isEnabled = false
//            } else {
//                self.streamButton.isEnabled = true
//            }
            self.isPlayable = buffer.isReadyForPlaying
        }
        
        queueId = SAPlayer.Updates.AudioQueue.subscribe { [weak self] key, forthcomingPlaybackUrl in
            guard let self = self else { return }
            /// we update the selected audio. this is a little contrived, but allows us to update outlets
            //                    if let indexFound = self.selectedAudio.getIndex(forURL: forthcomingPlaybackUrl) {
            //                        self.selectAudio(atIndex: indexFound)
            //                    }
            // todo some url waiting in queue
            
            print("💥 Received queue update 💥")
        }
    }
    
    func updateProgress(to progress: Double) {
        //        self.progressIsOnDrag = true
        self.playProgress = progress
    }
    
    func playOrPause(_ isDetailView: Bool = true)  {
        SAPlayer.shared.togglePlayAndPause()
    }
    
    
    func nextItem(_ isConnect: Bool = true) {
        SAPlayer.shared.nextAudio()
    }
    
    func skip(forward: Bool) {
        forward ? SAPlayer.shared.skipForward() : SAPlayer.shared.skipBackwards()
    }
    
    func progressSkip(to progress: Double) {
        SAPlayer.shared.seekTo(seconds: progress * duration)
    }
    
    // private method
    
    
    func testRemoveAllDownloadListfile(notificationHandle: @escaping (String)->Void) {
        var i = self.musicItemController!.downloadList.list.count - 1
        while i > 0 {
            let item = self.musicItemController?.downloadList.list[i]
            if item?.downloadState == nil {
                SAPlayer.Downloader.deleteDownloaded(withSavedUrl: item!.url)
            } else if let savedUrl = SAPlayer.Downloader.getSavedUrl(forRemoteUrl: item!.url) {
                SAPlayer.Downloader.deleteDownloaded(withSavedUrl: savedUrl)
            }
            self.musicItemController!.downloadList.list.remove(at: i)
            
            i -= 1
        }
        notificationHandle("reset")
        self.musicItemController?.downloadIndexMap.removeAll()
        
    }
    
    func handleDownloadStreamURL(surl: String, musicTitle: String, complateHandle: @escaping ()->Void, notificationHandle: @escaping (String)->Void) {
//        let urls: [URL] = [URL(string: "https://www.fesliyanstudios.com/musicfiles/2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com/15SecVersion2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com.mp3")!,
//                           URL(string: "https://chtbl.com/track/18338/traffic.libsyn.com/secure/acquired/acquired_-_armrev_2.mp3?dest-id=376122")!
//        ]
        
        let rurl = URL(string: surl)!
//        if SAPlayer.Downloader.isDownloaded(withRemoteUrl: rurl)
        if let _ = SAPlayer.Downloader.getSavedUrl(forRemoteUrl: rurl) {
            // has downloaded
//            SAPlayer.Downloader.deleteDownloaded(withSavedUrl: savedUrl)
////            print("tart \(savedUrl.absoluteString)")
//            for i in 0..<self.musicItemController!.downloadList.list.count {
//                let a = ((self.musicItemController?.downloadList.list[i].url.absoluteString ?? "sfsafsajlfsjflds") as NSString).substring(from: 7)
//                let b = (savedUrl.absoluteString as NSString).substring(from: 15)
//                if a == b {
//                    notificationHandle("重复下载，测试需要暂时删除")
//                    musicItemController?.downloadList.list.remove(at: i)
//                    break
//                }
//            }
//            SAPlayer.Downloader.deleteDownloaded(withSavedUrl: SAPlayer.Downloader.getSavedUrl(forRemoteUrl: rurl)!)
            notificationHandle("重复下载")
        } else {
            // to download...
            DispatchQueue.main.async {
                self.musicItemController?.insertOrUpdateDownloadList(url: rurl, songTitle: musicTitle, downState: .downloading)
            }
            self.isDownloading = true
            SAPlayer.Downloader.downloadAudio(withRemoteUrl: rurl, completion: { [weak self] url in
                guard let self = self else { return }
                print("down load complated")
                if let index = self.musicItemController?.downloadIndexMap[surl] {
                    var item = self.musicItemController?.downloadList.list[index]
                    if item?.url.absoluteString == surl { // 多此一举，后面删
                        item?.url = url
                        item?.loc = .disk
                        item?.downloadState = nil
                        do {
                            let id3Tag  = ID3TagEditor()
                            if let id3Tag = try id3Tag.read(mp3: Data(contentsOf: url)) {
                               
                                if let title = (id3Tag.frames[.title] as?  ID3FrameWithStringContent)?.content {
                                   item?.mediaInfo?.title = title
                                    print("songtitle: \(title)")
                                }
                                if let artist = (id3Tag.frames[.artist] as? ID3FrameWithStringContent)?.content {
                                    item?.mediaInfo?.artist = artist
//                                    print("songartis: \(artist)")
                                }
                                if let album = (id3Tag.frames[.album] as? ID3FrameWithStringContent)?.content {
                                    item?.mediaInfo?.albumTitle = album
                                }
                                //todo insert artwork
//                                if let artwork = UIImage(data: (id3Tag.frames[.attachedPicture(.fileIcon)] as!  ID3FrameAttachedPicture).picture) {
//                                    item?.mediaInfo?.artwork = MPMediaItemArtwork(image: artwork)
//                                }
                                
                            }
                        } catch {
                            print(error)
                        }
                        
                        DispatchQueue.main.async {
                            self.downloadProgress = 0
                            self.isDownloading = false
                            complateHandle()
                            self.musicItemController?.downloadList.list[index] = item!
                        }
                        return
                    }
                }

            })
             
            
            
//            if SAPlayer.Downloader.isDownloaded(withRemoteUrl: surl) {
            //todo pause to switch .queue
            
//            } else {
//                musicItemController?.insertDownloadList(urlString: surl.absoluteString, songTitle: musicTitle, downState: .queue)
//            }
            
        }
    }
    
    func handlePlayStreamURL(surl: String, musicTitle: String, notificationHandle: @escaping (String)->Void) {
//        let urls: [URL] = [URL(string: "https://www.fesliyanstudios.com/musicfiles/2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com/15SecVersion2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com.mp3")!,
//                           URL(string: "https://chtbl.com/track/18338/traffic.libsyn.com/secure/acquired/acquired_-_armrev_2.mp3?dest-id=376122")!
//        ]
        let rurl = URL(string: surl)!
        if let index = self.musicItemController?.downloadIndexMap[surl] {
            // 重复play play play 就是暂停
            if index == musicItemController?.currentIndex && musicItemController?.collectionIndex == 1 {
                self.playOrPause()
            }
            // 判断是否已下载，如果是直接播放
            else if let _ = SAPlayer.Downloader.getSavedUrl(forRemoteUrl: rurl)  {
                self.musicItemController!.prepareToNextItem(index, collectionIndex: 1)
                self.nextItem(false)
//                notificationHandle("已下载或正在下载中，立即播放")
            }
            print("已在列表中")
        } else {
            if SAPlayer.Downloader.isDownloaded(withRemoteUrl: rurl) {
                notificationHandle("缓存播放...")
            }
            // buffering play
            DispatchQueue.main.async {
                if let hasIndex = self.musicItemController?.insertOrUpdateDownloadList(url: rurl, songTitle: musicTitle, downState: .buffering, songState: .remote) {
                    self.musicItemController!.prepareToNextItem(hasIndex, collectionIndex: 1)
                    self.nextItem(false)
                }
                
            }
//            let mediaInfo = SALockScreenInfo(title: musicTitle, artist: rurl.absoluteString, artwork: nil, releaseDate: 0, albumTitle: "")
//            SAPlayer.shared.startRemoteAudio(withRemoteUrl: rurl, bitrate: .high, mediaInfo: mediaInfo)

        }
    }
    
    
    
    private func getFileUrl(control: PlayControl = .current) -> QueueItem? {
        //        guard let fileURL = Bundle.main.url(forResource: "Intro", withExtension: "mp3") else {
        //          return nil
        //        }
        //        let monv = MPMediaQuery.songs().items![131]
        //        return monv.assetURL!
        let song: QueueItem?
        switch control {
        case .current:
            song =  self.musicItemController?.currentPlay
        case .next:
            song =  self.musicItemController?.nextItem()
        case .previous:
            song =  self.musicItemController?.previousItem()
        }
        guard let _ = song?.url else { return nil }
        return song
    }
    
    private func setupAudio() {
        
    }
    
    private func scheduleAudioFile(control: PlayControl = .current) -> Bool {
        
        return true
    }
    
    private func seek(to time: Double) {
        
        
    }
    
}


/*
 struct PlaybackValue {
 var value: Double
 var label: String
 var id: String {
 return "\(label)-\(value)"
 }
 }
 
 enum PlayControl {
 case current
 case next
 case previous
 }
 
 
 
 
 
 class AVEnginePlayerModel: NSObject, ObservableObject {
 
 // public var
 //    DirectorThreadSafeClosure
 
 @Published var isPlaying = false
 @Published var isPlayerReady = false
 
 @Published var playbackRateIndex: Int = 2 {
 didSet {
 // todo
 timeEffect.rate = Float(allPlaybackRates[playbackRateIndex].value)
 }
 }
 
 @Published var playbackPitchIndex: Int = 1 {
 didSet {
 timeEffect.pitch = 1200 * Float(allPlaybackPitches[playbackPitchIndex].value)
 }
 }
 
 @Published var playProgress: Double = 0 {
 didSet {
 //            seek(to: offsetTime)
 }
 }
 
 @Published var playerTime: Double = 0
 @Published var totalTime: Double = 0
 @Published var meterLevel: Float = 0
 @Published var waveGraphData: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
 
 var musicItemController: MusicItemPlayerController? = nil
 
 let allPlaybackRates: [PlaybackValue] = [
 .init(value: 0.25, label: "0.25x"),
 .init(value: 0.5, label: "0.5x"),
 .init(value: 1, label: "1x"),
 .init(value: 1.25, label: "1.25x"),
 .init(value: 2, label: "2x"),
 .init(value: 4, label: "4x")
 ]
 
 var allPlaybackPitches: [PlaybackValue] = [
 .init(value: -0.5, label: "-½"),
 .init(value: 0, label: "0"),
 .init(value: 0.5, label: "+½")
 ]
 
 // private var
 private var engine = AVAudioEngine()
 private var player = AVAudioPlayerNode()
 
 private var timeEffect = AVAudioUnitTimePitch()
 private var displayLink: CADisplayLink?
 
 private var needFileScheduled = true
 private var audioFile: AVAudioFile?
 private var audioSampleRate: Double = 0
 private var audioLenghSeconds: Double {
 audioSampleRate == 0 ? 0 : Double(audioFrameTotalLength) / audioSampleRate
 }
 
 //    private var seekFrame: AVAudioFramePosition = 0
 private var audioFrameTotalLength: AVAudioFramePosition = 0
 private var currentFramePosition: AVAudioFramePosition = 0
 private var audioLengthSamples: AVAudioFramePosition = 0
 private var skipFrames: AVAudioFramePosition = 0
 private var progressIsOnDrag: Bool = false
 
 private var currentFrameByPlayer: AVAudioFramePosition {
 guard
 let lastRenderTime = player.lastRenderTime,
 let playerTimer = player.playerTime(forNodeTime: lastRenderTime)
 else {
 return 0
 }
 //        print("lastRenderTime:\(lastRenderTime.sampleTime)    playerTimer:\(playerTimer.sampleTime)")
 return playerTimer.sampleTime < 0 ? 0 : playerTimer.sampleTime
 }
 
 
 // public method
 
 override init() {
 super.init()
 }
 
 convenience init(_ musicItemController: MusicItemPlayerController) {
 self.init()
 self.musicItemController = musicItemController
 setupAudio()
 setupDisplink()
 
 }
 
 func setPlayerVolumeTest() {
 self.player.volume += 0.1
 }
 
 
 func formattedTime(time: Double) -> String {
 var seconds = Int(round(time))
 var hours = 0
 var mins = 0
 
 if seconds > 3600 {
 hours = seconds / 3600
 seconds -= hours * 3600
 }
 
 if seconds > 60 {
 mins = seconds / 60
 seconds -= mins * 60
 }
 
 var formattedString = ""
 if hours > 0 {
 formattedString = "\(String(format: "%02d", hours)):"
 }
 formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", seconds))"
 return formattedString
 }
 
 func skip(forwards: Bool) {
 //        let time: UInt = 15
 seek(to: forwards ? 15 : -15)
 }
 
 func progressSkip(to progress: Double) {
 let seekTime = totalTime * progress - playerTime
 seek(to: seekTime)
 self.progressIsOnDrag = false
 }
 
 func updateProgress(to progress: Double) {
 self.progressIsOnDrag = true
 self.playProgress = progress
 }
 
 func playOrPause(_ isDetailView: Bool = true)  {
 //        DispatchQueue.main.async {
 self.isPlaying.toggle()
 //        }
 
 if player.isPlaying {
 player.pause()
 engine.pause()
 displayLink?.isPaused = true
 if isDetailView {
 disconnectVolumeTap()
 }
 } else {
 //            print("play Scheduled: \(needFileScheduled)")
 if needFileScheduled {
 let _ = scheduleAudioFile()
 }
 if isDetailView {
 connectVolumeTap()
 }
 displayLink?.isPaused = false
 do {
 try engine.start()
 } catch {
 
 }
 player.play()
 }
 updateNowPlaying()
 }
 
 
 func nextItem(_ isConnect: Bool = true) {
 disconnectVolumeTap()
 player.pause()
 engine.pause()
 //            needFileScheduled = true
 skipFrames = 0
 isPlaying = false
 displayLink?.isPaused = true
 currentFramePosition = 0
 playProgress = 0
 totalTime = Double(audioFrameTotalLength) / Double(audioSampleRate)
 playerTime = 0
 
 // switch music
 let _ = scheduleAudioFile(control: .next)
 if isConnect {
 connectVolumeTap()
 }
 displayLink?.isPaused = false
 do {
 try engine.start()
 } catch {}
 player.play()
 isPlaying = true
 setupNowPlaying()
 updateNowPlaying()
 }
 
 // private method
 
 
 
 
 private func getFileUrl(control: PlayControl = .current) -> URL? {
 //        guard let fileURL = Bundle.main.url(forResource: "Intro", withExtension: "mp3") else {
 //          return nil
 //        }
 //        let monv = MPMediaQuery.songs().items![131]
 //        return monv.assetURL!
 let url: URL?
 switch control {
 case .current:
 url =  self.musicItemController?.currentPlay?.assetURL
 case .next:
 url =  self.musicItemController?.nextItem()
 case .previous:
 url =  self.musicItemController?.previousItem()
 }
 
 guard let u = url else { return nil }
 return u
 }
 
 private func setupAudio() {
 
 engine.attach(player)
 engine.attach(timeEffect)
 setupRemoteTransportControls()
 //        setupNowPlaying()
 let _ = scheduleAudioFile()
 setupNowPlaying()
 }
 
 private func scheduleAudioFile(control: PlayControl = .current) -> Bool {
 guard let fileUrl = getFileUrl(control: control) else {
 return false
 }
 //        print("scheduleAudioFile")
 do {
 let file = try AVAudioFile(forReading: fileUrl)
 let format = file.processingFormat
 audioFile = file
 audioFrameTotalLength = file.length
 audioSampleRate = format.sampleRate
 totalTime = Double(audioFrameTotalLength) / audioSampleRate
 //            audioLenghSeconds = Double(audioFramLength) / audioSampleRate
 if engine.isRunning {
 print("reset engine")
 engine.stop()
 engine.reset()
 print(engine.attachedNodes)
 }
 engine.connect(player, to: timeEffect, format: format)
 engine.connect(timeEffect, to: engine.mainMixerNode, format: format)
 
 engine.prepare()
 
 //            try engine.start()
 //            print("need?: \(needFileScheduled)")
 //            scheduleAudioFile()
 // remove isready
 
 } catch let error {
 print("Error reading the audio file: \(error.localizedDescription)")
 }
 guard let file = audioFile, needFileScheduled else {
 return false
 }
 needFileScheduled = false
 skipFrames = 0
 player.scheduleFile(file, at: nil) {
 self.needFileScheduled = true
 //            self.playDidEndedDo()
 }
 return true
 }
 
 
 func playDidEndedDo() {
 // todo current is random
 if needFileScheduled {
 let _ = scheduleAudioFile(control: .next)
 }
 print("play did ended do something")
 
 // if timer stop { needFileScheduled = true }
 }
 
 // background audio /// control center
 func setupRemoteTransportControls() {
 // Get the shared MPRemoteCommandCenter
 let commandCenter = MPRemoteCommandCenter.shared()
 
 // Add handler for Play Command
 //        commandCenter.playCommand.isEnabled = true
 commandCenter.playCommand.addTarget { [unowned self] event in
 //            if self.player.rate == 1.0 {
 self.playOrPause()
 return .success
 //            }
 //            return .commandFailed
 }
 
 // Add handler for Pause Command
 //        commandCenter.pauseCommand.isEnabled = true
 commandCenter.pauseCommand.addTarget { [unowned self] event in
 //            if self.player.rate == 1.0 {
 self.playOrPause()
 return .success
 //            }
 //            return .commandFailed
 }
 commandCenter.bookmarkCommand.addTarget { [unowned self] event in
 //            if self.player.rate == 1.0 {
 self.playOrPause()
 return .success
 //            }
 //            return .commandFailed
 }
 
 commandCenter.nextTrackCommand.addTarget{ [unowned self] event in
 self.nextItem()
 return .success
 }
 //        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
 ////
 //            self.seek(to: 15)
 //            return .success
 //        }
 commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] commandEvent in
 if let event = commandEvent as? MPChangePlaybackPositionCommandEvent {
 seek(to: event.positionTime - playerTime)
 print("positionTime: \(event.positionTime)")
 }
 return .success
 }
 }
 
 func setupNowPlaying() {
 //         Define Now Playing Info
 var nowPlayingInfo = [String : Any]()
 
 if let image = self.musicItemController?.currentPlay?.artwork?.image(at: CGSize(width: 20, height: 20)) {
 nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
 return image
 }
 } else {
 let image = UIImage.init(named: "1012880")
 nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image?.size ?? CGSize(width: 20, height: 20)) { size in
 return image!
 }
 }
 //        } else  UIImage(named: "artist")
 // nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
 nowPlayingInfo[MPMediaItemPropertyTitle] = self.musicItemController?.currentPlay?.title ?? ""
 nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.musicItemController?.currentPlay?.albumTitle ?? ""
 nowPlayingInfo[MPMediaItemPropertyArtist] = self.musicItemController?.currentPlay?.artist ?? ""
 
 nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =  playerTime // audioSampleRate
 nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalTime - playerTime // audioSampleRate
 nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
 //        MPNowPlayingInfoCenter.default().playbackState = .paused
 // Set the metadata
 MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
 }
 
 
 func updateNowPlaying() {
 // Define Now Playing Info
 var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
 
 nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerTime
 nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? allPlaybackRates[playbackRateIndex].value : 0
 // Set the metadata
 //        if MPNowPlayingInfoCenter.default().playbackState == .playing {
 //            MPNowPlayingInfoCenter.default().playbackState = .paused
 //        } else {
 //            MPNowPlayingInfoCenter.default().playbackState = .playing
 //        }
 
 MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
 }
 
 private func seek(to time: Double) {
 guard let file = audioFile else {
 return
 }
 // saved playing state
 let wasPlaying = player.isPlaying
 player.stop()
 
 let offset = AVAudioFramePosition(time * audioSampleRate)
 skipFrames = currentFramePosition + offset
 skipFrames = max(0, skipFrames)
 skipFrames = min(skipFrames, audioFrameTotalLength)
 currentFramePosition = skipFrames
 if skipFrames < audioFrameTotalLength {
 let frameCount = AUAudioFrameCount( audioFrameTotalLength - skipFrames )
 self.needFileScheduled = false
 player.scheduleSegment(file, startingFrame: skipFrames, frameCount: frameCount, at: nil) {
 // 顺序不能错
 //                self.playDidEndedDo()
 self.needFileScheduled = true
 }
 if wasPlaying {
 player.play()
 }
 updateDisplay() // ???
 } else {
 nextItem()
 }
 //
 
 }
 
 
 
 
 private func setupDisplink() {
 displayLink = CADisplayLink(target: self,
 selector: #selector(updateDisplay)
 )
 displayLink?.add(to: .current, forMode: .default)
 displayLink?.isPaused = true
 }
 
 
 @objc private func updateDisplay() {
 currentFramePosition = currentFrameByPlayer + skipFrames
 if currentFramePosition >= audioFrameTotalLength {
 player.pause()
 //            needFileScheduled = true
 skipFrames = 0
 isPlaying = false
 displayLink?.isPaused = true
 currentFramePosition = 0
 disconnectVolumeTap()
 nextItem()
 }
 
 if !progressIsOnDrag {
 let tmpP = Double(currentFramePosition) / Double(audioFrameTotalLength)
 //            print("progress: \(tmpP)")
 if abs(tmpP - playProgress) > 0.001 {
 playProgress = tmpP
 }
 }
 let tmpTT = Double(audioFrameTotalLength) / Double(audioSampleRate)
 if tmpTT != totalTime {
 totalTime = tmpTT
 }
 let tmpPT = Double(currentFramePosition) / Double(audioSampleRate)
 if abs(tmpPT - playerTime) >= 0.5 {
 playerTime = tmpPT
 }
 //        print("playTime: \(tmpPT)")
 
 }
 
 func connectVolumeTap() {
 let format = engine.mainMixerNode.outputFormat(forBus: 0)
 engine.mainMixerNode.installTap(onBus: 0,
 bufferSize: 1024,
 format: format)
 { buffer, audioTime in
 guard let channelData = buffer.floatChannelData else {
 return
 }
 let channelDataValue = channelData.pointee
 let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride)
 .map { i in
 channelDataValue[i]
 }
 
 var waveGraphDataCopy: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
 for x in 0..<8 {
 let startIndex = x * 128
 var endIndex = (x + 1) * 128
 if endIndex > buffer.frameLength {
 endIndex = Int(buffer.frameLength)
 break
 }
 let rms = channelDataValueArray[startIndex..<endIndex].map({ x in
 return powf(x, 2.0)
 })
 .reduce(0, +) / Float(endIndex - startIndex)
 let avgPower = 20 * log10(rms)
 waveGraphDataCopy[x] = Double(self.scaledPower(power: avgPower))
 }
 
 let rms = sqrt(channelDataValueArray.map({ x in
 return powf(x, 2.0)
 })
 .reduce(0, +) / Float(buffer.frameLength)
 )
 let avgPower = 20 * log10(rms)
 let meterLevel = self.scaledPower(power: avgPower)
 DispatchQueue.main.async {
 self.meterLevel = self.isPlaying ? meterLevel : 0
 self.waveGraphData = waveGraphDataCopy
 }
 }
 
 // { AVAudioPCMBuffer, <#AVAudioTime#>
 
 
 }
 
 func disconnectVolumeTap() {
 engine.mainMixerNode.removeTap(onBus: 0)
 DispatchQueue.main.async {
 self.meterLevel = 0
 }
 
 }
 
 private func scaledPower(power: Float) -> Float {
 guard power.isFinite else {
 return 0.0
 }
 
 let minDb: Float = -80
 
 if power < minDb {
 return 0.0
 } else if power >= 1.0 {
 return 1.0
 } else {
 return (abs(minDb) - abs(power)) / abs(minDb)
 }
 }
 }
 
 */
