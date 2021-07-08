//
//  MusicItemPlayeController.swift
//  timer
//
//  Created by linhai on 2021/6/21.
//

import Foundation
import AVFoundation
import MediaPlayer


class MusicItemPlayerController: NSObject, ObservableObject {
    
    @Published var currentPlay: MPMediaItem? = nil
    @Published var musicList: [MPMediaItem] = []
    @Published var currentIndex: Int = -1
    
    private var isPrepareToNextItem: Bool = false
    private var nextItemIndex: Int = 0
    var isRandom = true
    var url: URL? {
        if currentPlay != nil {
            guard let u = currentPlay?.assetURL else { return nil }
            return u
        } else {
            if musicList.count > 0 {
                currentIndex = isRandom ? Int(arc4random_uniform(UInt32(musicList.count))) : 0
                currentPlay = musicList[currentIndex]
                guard let u = currentPlay?.assetURL else { return nil }
                return u
            } else {
                return nil
            }
        }
    }
    override init() {
        super.init()
        self.musicList = getLocalMusicList()
        let _ = url
    }
    
    func prepareToNextItem(_ index: Int) {
        nextItemIndex = index
        isPrepareToNextItem = true
    }
    
    func getUrlStreamAudioFile() -> URL? {
//        URLSession(configuration: )
        return nil
    }
    
    func nextItem() -> URL? {
        if isPrepareToNextItem {
            isPrepareToNextItem = false
            currentIndex = nextItemIndex
        } else {
            currentIndex = isRandom ? Int(arc4random_uniform(UInt32(musicList.count))) : currentIndex + 1
            if currentIndex >= musicList.count {
                currentIndex = 0
            }
        }
        currentPlay = musicList[currentIndex]
        guard let u = currentPlay?.assetURL else { return nil }
        return u
    }
    
    
    func previousItem() -> URL? {
        currentIndex = isRandom ? Int(arc4random_uniform(UInt32(musicList.count))) : currentIndex - 1
        if currentIndex < 0 {
            currentIndex = musicList.count - 1
        }
        currentPlay = musicList[currentIndex]
        guard let u = currentPlay?.assetURL else { return nil }
        return u
    }
    
    
    private func loadLocalStorage() {}
    
    private func getLocalMusicList() -> [MPMediaItem]{
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
            return []
        }
        return songsList
        
    }
}
