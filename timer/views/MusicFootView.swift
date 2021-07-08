//
//  MusicPlayFootView.swift
//  timer
//
//  Created by linhai on 2021/6/23.
//

import SwiftUI

struct MusicFootView: View {
    
    @StateObject var musicItemConroller: MusicItemPlayerController
    @StateObject var player: AVEnginePlayerModel
    var body: some View {

        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
            
            if musicItemConroller.currentPlay?.artwork != nil {
                Image(uiImage: (musicItemConroller.currentPlay?.artwork!.image(at: CGSize(width: 40, height: 40)))! )
                    .resizable()
                    //                                    .scaleEffect(19)
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .clipShape(Circle())
                    .offset(x: 13, y: -5.0)
                    .scaleEffect(1.2)
                    .padding([.trailing], 30)
            } else {
                Image("1012880")
                    .resizable()
                    //                                    .scaleEffect(19)
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .clipShape(Circle())
                    .offset(x: 13, y: -5.0)
                    .scaleEffect(1.2)
                    .padding([.trailing], 30)
            }
            
            
            Text(musicItemConroller.currentPlay?.title ?? "未播放")
                .lineLimit(1)
                .font(.custom("title", size: 17))
                .foregroundColor(.black)
//            musicItemConroller.currentPlay?.artist.co
            if musicItemConroller.currentPlay?.artist != nil {
                Text(" - \(musicItemConroller.currentPlay?.artist ?? "")")
                    .lineLimit(1)
                    .foregroundColor(.black)
                    .font(.custom("aritist", size: 13))
            }
            
            Spacer()
                
                ZStack(alignment: /*@START_MENU_TOKEN@*/Alignment(horizontal: .center, vertical: .center)/*@END_MENU_TOKEN@*/, content: {
                    
                    Image(systemName: player.isPlaying ? "pause" : "play")
                        .foregroundColor(.black)
                    //                Image(systemName: "pause")
                    Circle()
                        .stroke(style: .init(lineWidth: 1))
                        .frame(width: 38, height: 38, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.systemGray)
                    
                    Path { path in
                        // radius 是半径
                        path.addRelativeArc(center: .init(x: 18, y: 18), radius: 19, startAngle: .init(degrees: -90), delta: Angle(degrees: player.playProgress * 360))
                        
                    }
                    .stroke(Color.pink, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//                    .animation(.interactiveSpring())
                    .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                //            .foregroundColor(.gray)
                .padding([.trailing], 15)
                .contentShape(Rectangle())
                .onTapGesture {
//                    DispatchQueue.main.async {
                        self.player.playOrPause(false)
//                    }
                    
//                    print("play or pause")
                }
            
            
            Image(systemName: "forward.end")
            .foregroundColor(.black)
            .padding([.trailing], 10)
            .contentShape(Rectangle())
            .onTapGesture {
//                print(">>")
//                DispatchQueue.main.async {
                    self.player.nextItem()
//                }
                
            }
        })
        .foregroundColor(.white)
    }
    
}

struct MusicPlayFootView_Previews: PreviewProvider {
    static let musicController = MusicItemPlayerController()
    static let player = AVEnginePlayerModel(musicController)
    static var previews: some View {
        MusicFootView(musicItemConroller: musicController, player: player)
    }
}
