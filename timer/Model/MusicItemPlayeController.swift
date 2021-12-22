//
//  MusicItemPlayeController.swift
//  timer
//
//  Created by linhai on 2021/6/21.
//

import Foundation
import AVFoundation
import MediaPlayer

struct QueueItem {
    var loc: Location
    var url: URL
    var mediaInfo: SALockScreenInfo?
    var bitrate: SAPlayerBitrate
    var mediaItem: MPMediaItem?
    var downloadState: DownState?

    init(loc: Location, url: URL, mediaInfo: SALockScreenInfo?, bitrate: SAPlayerBitrate = .high, mediaItem: MPMediaItem?) {
        self.loc = loc
        self.url = url
        self.mediaInfo = mediaInfo
        self.bitrate = bitrate
        self.mediaItem = mediaItem
    }
}

enum Location {
    case remote
    case disk
    case cache
}

enum DownState {
    case downloading
    case queue
    case buffering
}

class QueueItemList:  ObservableObject{
    var list : [QueueItem] = []
}

class MusicItemPlayerController: NSObject, ObservableObject {

    
    struct QueueItemCollection {
        var items: [QueueItem]
    }

    @Published var currentPlay: QueueItem? = nil
    @Published var musicList = QueueItemList()
    @Published var downloadList = QueueItemList()
    @Published var currentIndex: Int = -1
    var musicListCollections : [QueueItemList] = []
    
    public static var shared = MusicItemPlayerController()
    var downloadIndexMap = [String: Int]()
    private var isPrepareToNextItem: Bool = false
    private var nextItemIndex: Int = 0
    var isRandom = false
    var collectionIndex = 0
    var url: URL? {
        if currentPlay != nil {
            guard let u = currentPlay?.url else { return nil }
            return u
        } else {
            if musicList.list.count > 0 {
                currentIndex = isRandom ? Int(arc4random_uniform(UInt32(musicList.list.count))) : 0
                currentPlay = musicList.list[currentIndex]
                guard let u = currentPlay?.url else { return nil }
                return u
            } else {
                return nil
            }
        }
    }
    override init() {
        super.init()
        getLocalMusicList()
        let _ = url
        self.musicListCollections.append(self.musicList)
        self.musicListCollections.append(self.downloadList)
//        self.musicListCollections.append( &self.musicList )
    }

    
    func prepareToNextItem(_ index: Int, collectionIndex: Int = 0) {
        self.collectionIndex = collectionIndex
        nextItemIndex = index
        isPrepareToNextItem = true
    }
    
    
    
    func getUrlStreamAudioFile() -> URL? {
//        URLSession(configuration: )
        return nil
    }
    
    func nextItem() -> QueueItem? {
        if isPrepareToNextItem {
            isPrepareToNextItem = false
            currentIndex = nextItemIndex
        } else {
            currentIndex = isRandom ? Int(arc4random_uniform(UInt32(self.musicListCollections[self.collectionIndex].list.count))) : currentIndex + 1
            if currentIndex >= self.musicListCollections[self.collectionIndex].list.count {
                currentIndex = 0
            }
        }
//        print("\(self.collectionIndex):\(currentIndex)")
        currentPlay = self.musicListCollections[self.collectionIndex].list[currentIndex]
        guard let _ = currentPlay?.url else { return nil }
        return currentPlay
    }
    
    
    func previousItem() -> QueueItem? {
        currentIndex = isRandom ? Int(arc4random_uniform(UInt32(musicList.list.count))) : currentIndex - 1
        if currentIndex < 0 {
            currentIndex = musicList.list.count - 1
        }
        currentPlay = musicList.list[currentIndex]
        guard let _ = currentPlay?.url else { return nil }
        return currentPlay
    }
    
    
    func insertOrUpdateDownloadList(url: URL, songTitle: String, downState: DownState, songState: Location = .cache) -> Int? {
        if let hasIndex = downloadIndexMap[url.absoluteString] {
            // from play to download
            var item = downloadList.list[hasIndex]
            if downState == .downloading {
                item.downloadState = downState
                self.downloadList.list[hasIndex] = item
            } else {
                
            }
            return hasIndex
            
        } else {
            let mediaInfo = SALockScreenInfo(title: songTitle, artist: url.absoluteString, artwork: nil, releaseDate: 0, albumTitle: "")
            var cacheItem = QueueItem(loc: songState, url: url, mediaInfo: mediaInfo, mediaItem: nil)
            cacheItem.downloadState = downState
            self.downloadIndexMap[url.absoluteString] = downloadList.list.count
            self.downloadList.list.append(cacheItem)
            return downloadList.list.count - 1
        }
        return nil
        
    }
    
    private func loadLocalStorage() {}
    
    
    
    private func getLocalMusicList(){
        //        var mediaItem: [MPMediaItem] = []
        //
        //        MPMusicPlayerController.applicationMusicPlayer
        //        let mediaItems = MPMediaQuery.songs().items!
        //        let mediaCollection = MPMediaItemCollection(items: mediaItems)
        //        let mediaList = MPMediaPlaylist(items: mediaItems)
        //        print(mediaItems.count)
        //        print(mediaItems[0...3])
        //        print(mediaList.count, mediaList[0...3], mediaList[0])
        //        print(mediaCollection.count, mediaCollection[0...3], mediaCollection[0])
        print("song numbers: \(String(describing: MPMediaQuery.songs().items?.count))")
//        for song in MPMediaQuery.songs().items! {
//            print(song.albumTitle!, song.title!, song.artist!)
//
//        }
        print("----------------------------")
        //        let myAlbumsQuery = MPMediaQuery.albums()
        //
        //        let playlists = myAlbumsQuery.collections
        //        for playlist in playlists! {
        ////            playlist.value(forProperty: )
        ////            print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
        //            let songs = playlist.items
        //            for song in songs {
        //                print(song.albumTitle, song.title)
        ////                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
        ////                print("\t\t", songTitle!)
        //            }
        //        }
        // placeholder
        guard  let songsList = MPMediaQuery.songs().items  else {
            return
        }
        var x : [QueueItem] = []
        for song in songsList {
            x.append(QueueItem(loc: .disk, url: song.assetURL!, mediaInfo:
                                SALockScreenInfo(title: song.title ?? "",
                                                 artist: song.artist ?? "" ,
                                                 artwork: song.artwork,
                                                 releaseDate: UTC(song.releaseDate?.timeIntervalSince1970 ?? .zero),
                                                 albumTitle: song.albumTitle ?? ""),
                               mediaItem: song
                              ))
        }
        self.musicList.list = x
        let song = songsList[0]
        // for test
        downloadList.list.append(QueueItem(loc: .disk, url: song.assetURL!, mediaInfo:
                                        SALockScreenInfo(title: song.title ?? "",
                                                         artist: song.artist ?? "" ,
                                                         artwork: song.artwork,
                                                         releaseDate: UTC(song.releaseDate?.timeIntervalSince1970 ?? .zero),
                                                         albumTitle: song.albumTitle ?? ""),
                                       mediaItem: song
                                      ))
        
    }
}
