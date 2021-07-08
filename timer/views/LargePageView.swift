//
//  LargePageView.swift
//  timer
//
//  Created by linhai on 2021/6/25.
//

import SwiftUI
import MediaPlayer

struct LargePageView: View {
//    var pages: [Page]
    var musicItem: MusicItemPlayerController
    @State var currentPage = 0
    var body: some View {
        if musicItem.musicList.count == 0 {
            Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/)
        } else {
            ZStack(alignment: .bottomTrailing) {
//                NavigationLink(destination: Text("TextLarger")) {
                    PageViewController(pages: musicItem.musicList.filter({ music in
                        music.artwork != nil
                    }).shuffled().map({ music in
                        FeatureCard(music: music)
                            
                    }) ,
                                       currentPage: $currentPage)
//                }
                
                
                PageControl(numberOfPage: musicItem.musicList.filter({ music in
                    music.artwork != nil
                }).count, currentPage: $currentPage)
                
                    .frame(width: CGFloat(musicItem.musicList.filter({ music in
                        music.artwork != nil
                    }).count * 18))
                    .padding(.trailing)
            }
        }
        
    }
}


struct FeatureCard: View {
    
    var music: MPMediaItem
    var recCGSize: CGSize = CGSize(width: 380, height: 160)
    var body: some View {
//        if music.artwork != nil {
        
            ZStack(alignment: .center) {
                Image("iphone0\(Int.random(in: 1..<5))")
                    .resizable()
                    .aspectRatio( contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: recCGSize.width , height: recCGSize.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
//                    .padding()
//                    .border(Color.blue, width: 3.0)
                HStack(alignment: .center, spacing: nil) {
                    Spacer()
                    Image(uiImage: (music.artwork!.image(at: CGSize(width: recCGSize.height * 0.75, height: recCGSize.height * 0.75) ))! )
//                        .resizable()
//                        .scaleEffect(0.75)
    //                    .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: recCGSize.height * 0.75 , height: recCGSize.height * 0.75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .shadow(radius: 10)
                        .offset(x: -recCGSize.height * 0.15)
                }
                TextOverlay(media: music)
                    .overlay(TextOverlay(media: music))
            }
//            .aspectRatio(contentMode: .fill)
//            .ignoresSafeArea( edges: .all)
//            .frame(width: recCGSize.width , height: recCGSize.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct TextOverlay: View {
    var media: MPMediaItem
    
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
            HStack(alignment: .center, spacing: nil) {
                Text(media.title ?? "未知歌曲")
                    .font(.title)
                    .bold()
                Text(media.artist ?? "未知歌手")
            }
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct LargePageView_Previews: PreviewProvider {
    static let music = MusicItemPlayerController()
    static var previews: some View {
        LargePageView(musicItem: music)
    }
}
