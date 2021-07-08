//
//  SongListView.swift
//  timer
//
//  Created by linhai on 2021/6/20.
//

import SwiftUI
import SwiftUIX


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SongListView: View {
    
    @StateObject var musicItemController: MusicItemPlayerController
    @StateObject var player: AVEnginePlayerModel
//    @State var listOffset: CGFloat
    @StateObject var scrollViewOffset: ScrollOffsetModel
//    var listOffsetValue: CGFloat
    var body: some View {
        
        ScrollView {
            ScrollViewReader { proxy in
                ZStack {
                    LazyVStack {
                        ForEach(0..<musicItemController.musicList.count, id: \.self) { i in
                            lineContenView(musicItemController: musicItemController, player: player, i: i)
                                .padding([.leading, .trailing], 8)
                                .padding([.top], 3)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if self.musicItemController.currentIndex == i {
                                        self.player.playOrPause(false)
                                    } else {
                                        self.musicItemController.prepareToNextItem(i)
                                        self.player.nextItem(false)
                                    }
                                }
                        }
                    }
                    .onAppear {
//                        print("app offset", self.scrollViewOffset.getOOffset())
//                        proxy.scrollTo(20)
                        proxy.scrollTo(Int(self.scrollViewOffset.getOOffset()/60.95), anchor: .top)
                    }
                    .onDisappear {
                        self.scrollViewOffset.setOOffset(f: self.scrollViewOffset.copyOffset)
//                        print("dis offset", self.scrollViewOffset.copyOffset)
                    }
                    GeometryReader {
                        
                        Color.clear.preference(key: ViewOffsetKey.self,
                                               value: -$0.frame(in: .named("scroll")).origin.y)
                    }
                    
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ViewOffsetKey.self) { value in
//            DispatchQueue.main.async {
            self.scrollViewOffset.copyOffset = value
//                self.scrollViewOffset.setOOffset(f: value)
//            }
            
//            print("self update", self.scrollViewOffsetValue.offset)
        }
//        .navigationTitle(landmark.name)
        .navigationBarTitleDisplayMode(.inline)
        
//                .id(UUID())
        
    }
    
}


struct lineContenView: View {
    @StateObject var musicItemController: MusicItemPlayerController
    @StateObject var player: AVEnginePlayerModel
    
    var i: Int
    var body: some View {
        HStack(alignment: .center, spacing: 5, content: {
            Text("\(i+1)")
                .font(.system(.caption2, design: .monospaced))
                .bold()
//                .opacity(0.8)
                .foregroundColor(.gray)
                .frame(width: 22, height: 20)
            if  musicItemController.currentIndex == i {
                Image(systemName: player.isPlaying ? "pause":"play")
            }
            if musicItemController.musicList[i].artwork != nil {
                Image(uiImage: (musicItemController.musicList[i].artwork!.image(at: CGSize(width: 40, height: 40)))! )
                    .resizable()
                    .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            } else {
                Image("iphone02")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
            VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text(musicItemController.musicList[i].title!)
                    .font(.custom("title", size: 17))
                    .lineLimit(1)
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 2, content: {
                    Image(systemName: "heart.fill")
                    Text(musicItemController.musicList[i].artist!)
                        .font(.custom("title", size: 13))
                        .lineLimit(1)
                        .foregroundColor(.gray)
                    Text(musicItemController.musicList[i].albumTitle!)
                        .font(.custom("title", size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                })
                
            })
            Spacer()
            // line list ellipsis.circle
            Image(systemName: "ellipsis")
                .rotationEffect(Angle(degrees: 90))
                .scaleEffect(1.0)
//                .padding([ .trailing], 10)
        })
        
    }
}


class ScrollOffsetModel: ObservableObject {
    var offset: CGFloat = 0
    
    var copyOffset: CGFloat = 0
    
    func setOOffset(f: CGFloat) {
        offset = f
    }
    
    func getOOffset() -> CGFloat {
        offset
    }
}

struct SongListView_Previews: PreviewProvider {
    static let musicItemController = MusicItemPlayerController()
    static let player =  AVEnginePlayerModel(musicItemController)
    static let offset = ScrollOffsetModel()
    static var previews: some View {
        SongListView(musicItemController: musicItemController, player: player , scrollViewOffset: offset)
    }
}

