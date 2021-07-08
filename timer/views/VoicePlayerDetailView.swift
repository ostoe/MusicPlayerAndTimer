//
//  VoicePlayerView.swift
//  timer
//
//  Created by linhai on 2021/6/9.
//

import SwiftUI
import UIKit
import MediaPlayer
import SwiftUIX

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

struct VoicePlayerDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var player: AVEnginePlayerModel
    @State var pre: [Double] = [0.2, 0.8, 0.5, 1.0, 0.9, 0.1, 0.6, 0.5]
    let screenSize: CGRect = UIScreen.main.bounds
    @State var progressScale: Double = 1.0
    @State var basePreOffset: CGFloat = 0
    @State var soundLevel: Float = 0.1
    @State var systemVolume: Float = (MPVolumeView().subviews.first(where: { $0 is UISlider }) as! UISlider).value
    @State var volumeScale: Double = 1.0
    var body: some View {
        
        ZStack(alignment: .center) {
            Image("iphone03")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2)
                .blur(radius: 15)
                .edgesIgnoringSafeArea(.all)
//            VisualEffectBlurView()
            
//            VisualEffectView(effect: UIBlurEffect(style: .dark))
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                //            Button(action: {self.presentationMode.wrappedValue.dismiss()}, label: {
                //                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                //            })
    //            HStack {
                    Text(player.musicItemController?.currentPlay?.title ?? "")
                        .lineLimit(1)
                        .foregroundColor(.white)
                    Text(player.musicItemController?.currentPlay?.artist ?? "")
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .lineLimit(1)
    //            }
    //            .padding([.top], 10)
    //            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
               
    //            Spacer()
    //
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    
    //                    .frame(width: 50, height: 200, alignment: .center)
    //                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
    //                    .background(.black)
    //                    .frame()
                    if player.musicItemController?.currentPlay?.artwork != nil {
                        Image(uiImage: (player.musicItemController?.currentPlay?.artwork!.image(at: CGSize(width: 240, height: 240)))! )
                            .resizable()
                            //                                    .scaleEffect(19)
                            .frame(width: 240, height: 240, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
        //                    .offset(x: 13, y: -5.0)
        //                    .scaleEffect(1.2)
                            .padding([.trailing], 30)
                    } else {
                        Image("1012880")
                            .resizable()
                            //                                    .scaleEffect(19)
                            .frame(width: 240, height: 240, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .offset(x: 13, y: -5.0)
        //                    .scaleEffect(1.2)
                            .padding([.trailing], 30)
                    }
                    
                })
                
                let h: Double = 100
                let w: Double = 100
                //            var (h, w) = (240.0, 100.0)
                
                let spanceWidth = w / Double(player.waveGraphData.count - 1)
                Path { path in
                    let firstht = (1 - player.waveGraphData[0]) * h
                    
                    path.move(to: CGPoint(x: 0, y: firstht))
                    
                    //                pre.forEach { x in
                    //                    let ht = (1 - pre[$0]) * 100
                    //                    path.addQuadCurve(to: CGPoint(x: Double($0) * 30 ,
                    //                                                  y: ht),
                    //                                      control: CGPoint(x: Double($0-0.5) * 30 ,
                    //                                                       y: ht)
                    //                    )
                    //                }
                    //                print("player: \(player.waveGraphData)")
                    (1..<player.waveGraphData.count).forEach { i in
                        var scaledCuve:Double = 0.001
                        let leftht = (1 - player.waveGraphData[i-1]) * h
                        let rightht = (1 - player.waveGraphData[i]) * h
                        scaledCuve = leftht > rightht ? -scaledCuve : scaledCuve
                        // left control
                        let letfCGx = (Double(i)-0.65) * spanceWidth
                        let controlCGPoint1 = CGPoint(x: letfCGx, y: leftht * (1+scaledCuve))
                        // 736.0 + 414.0
                        //                    print("cp1 \(i): \(letfCGx), \(leftht * (1+scaledCuve))")
                        // right control
                        let rightCGx = (Double(i)-0.35) * spanceWidth
                        let controlCGPoint2 = CGPoint(x: rightCGx, y: rightht * (1-scaledCuve))
                        //                    print("cp2 \(i): \(rightCGx), \(rightht * (1+scaledCuve))")
                        // right point
                        let rightPoint = CGPoint(x: Double(i) * spanceWidth, y: rightht)
                        //                    print("au0 \(i): \(Double(i) * spanceWidth), \(rightht)")
                        path.addCurve(to: rightPoint, control1: controlCGPoint1, control2: controlCGPoint2)
                    }
                    
                }
                .stroke(lineWidth: 1.0)
                .foregroundColor(.gray)
                .animation(.spring())
                .frame(width: CGFloat(w), height: CGFloat(h), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                
                //            Text("Placeholder")
    //            Image(systemName: "mic")
    //                //                .scaledToFit()
    //                //                .resizable()
    //                .scaleEffect(2)
    //                .imageScale(.large)
    //                .aspectRatio(
    //                    nil,
    //                    contentMode: .fit)
    //                .padding()
    //                .layoutPriority(1)
                
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center), content: {
                    ProgressView(value: player.playProgress)
                        .accentColor(Color.pink)
    //                    .foregroundColor(.green)
                    CirclePointView(width: 30, heigth: 30, scale: CGFloat(progressScale))
    //                    .foregroundColor(.pink)
                        .accentColor(Color.pink)
                        .scaleEffect(0.5)
                        .position(x: CGFloat(player.playProgress) * (screenSize.width - 70), y: 10)
    //                    .offset(x: -30 + CGFloat(player.playProgress) * (screenSize.width - 70), y: 0)
    //                    .contentShape(Rectangle())
                        .gesture(DragGesture()
                                    .onChanged({ value in
                                        //                                    print(value.location.x, value.startLocation.x, value.predictedEndLocation.x)
                                        progressScale = 1.3
                                        if value.location.x >= 0 && value.location.x <= screenSize.width - 70 {
                                            let playProgress = Double((value.location.x) / (screenSize.width - 70))
                                            player.updateProgress(to: playProgress)
                                        }
                                    })
                                    .onEnded({ value in
                                        progressScale = 1.0
                                        // todo end play progress
                                        if value.location.x >= 0 && value.location.x <= screenSize.width - 70 {
                                            let progress = Double((value.location.x) / (screenSize.width - 70))
                                            player.progressSkip(to: progress)
                                        } else  if value.location.x > screenSize.width - 70 {
                                            player.progressSkip(to: 1)
                                        } else if value.location.x < 0 {
                                            player.progressSkip(to: 0)
                                        }
                                        //                                    print("on end \(value.location.x)")
                                    }))
    //
                        .frame(width: 20, height: 20, alignment: .leading)
                    
                })
                .padding([.leading, .trailing], 35)
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Text(player.formattedTime(time: player.playerTime))
                    Spacer()
                    Text(player.formattedTime(time: player.totalTime))
                })
                    .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
                .padding([.horizontal], 10)

                    
                PlayerButtons(player: player)
                    .foregroundColor(.white)
                    .padding([ .top], -10)
                
                HStack( spacing: 5) {
                    Image(systemName: "speaker")
                        .frame(width: 20, height: 10)
                    
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center), content: {
                    CustomVolumeView(volume: $systemVolume)
                        
                        .opacity(0)
                        .frame(width: 1, height: 1)
                        
                    let v = CustomVolumeView(volume: $systemVolume)
                    ProgressView(value: systemVolume)
                        .accentColor(Color.pink)
                    CirclePointView(width: 30, heigth: 30, scale: CGFloat(volumeScale))
                        .scaleEffect(0.5)
                        .position(x: CGFloat(systemVolume) * (screenSize.width - 120), y: 10)
    //                    .offset(x: -30 + CGFloat(player.playProgress) * (screenSize.width - 70), y: 0)
    //                    .contentShape(Rectangle())
                        .gesture(DragGesture()
                                    .onChanged({ value in
                                        //                                    print(value.location.x, value.startLocation.x, value.predictedEndLocation.x)
                                        volumeScale = 1.3
                                        if value.location.x >= 0 && value.location.x <= screenSize.width - 120 {
                                            let playProgress = Double((value.location.x) / (screenSize.width - 120))
                                            // todu update volume
    //                                        print("update\(playProgress)")
                                            
    //                                        MPVolumeView.setVolume(Float(playProgress))
                                            v.updateVolume(Float(playProgress))
                                        }
                                    })
                                    .onEnded({ _ in
                                        volumeScale = 1
                                    })
                        )
                        .frame(width: 20, height: 20, alignment: .leading)
                    
                })
                    Image(systemName: "speaker.wave.3")
                        .frame(width: 20, height: 10)
                }
                .foregroundColor(.white)
                .padding([.leading, .trailing], 35)
                .padding([.top], 20)
                
                
    //                .padding()
                PlayerControlButtons(player: player)
    //            VolumeView()
                
            })
        }
        
        //        .padding(.horizontal, 0)
        //        .onDrag({ /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Item Provider@*/NSItemProvider()/*@END_MENU_TOKEN@*/ })
        .contentShape(Rectangle())
        .offset(y: basePreOffset)
        .gesture(DragGesture()
                    .onChanged({ value in
                        
//                        print("localtion:", value.location.y, value.startLocation.y, value.translation.height)
//                        print("pre:", value.predictedEndTranslation.height, value.predictedEndLocation.y)
                        if value.startLocation.y < 395 {
                            basePreOffset = value.translation.height
                        }
                        
                    })
                    .onEnded({ value in
//                        print("\(value.predictedEndLocation.y)")
                        if value.predictedEndLocation.y >= 500 &&  value.startLocation.y < 395 {
//                          // self.presentationMode.wrappedValue.isPresented = true
                            if self.player.isPlaying {
                                self.player.disconnectVolumeTap()
                            }
                            
                            self.presentationMode.wrappedValue.dismiss()
//                          // self.presentationMode.wrappedValue.isPresented = false
                        } else {
                            basePreOffset = 0
                        }
                    })
        )
        
    }
    
    
   
    
    
}


struct PlayerButtons: View {
    @StateObject var player: AVEnginePlayerModel
    var body: some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
    //            Spacer()
    //            Button(action: {
    //                player.skip(forwards: false)
    //            }, label: {
    //                Image(systemName: "goforward.15")
    //            })
    //            .font(.title)
    //            .foregroundColor(Color.black)
            
            
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "backward.end")
            })
            .font(.title)
    //            .foregroundColor(Color.black)
            
            Spacer()
            Button(action: {
//                DispatchQueue.main.async {
                    player.playOrPause()
//                }
                
            }, label: {
                ZStack(alignment: /*@START_MENU_TOKEN@*/Alignment(horizontal: .center, vertical: .center)/*@END_MENU_TOKEN@*/, content: {
                    Color.pink
                        .frame(
                            width: 10,
                            // todo
                            height: 35 * CGFloat(player.meterLevel))
                        .opacity(0.5)
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                })
                
            })
            .font(.largeTitle)
    //            .foregroundColor(Color.black)
            Spacer()
            Button(action: {
                DispatchQueue.main.async {
                    player.nextItem()
                }
            }, label: {
                Image(systemName: "forward.end")
                    .scaleEffect(1.5)
    //                    .foregroundColor(.black)
            })
            Spacer()
    //            Button(action: {
    //                DispatchQueue.global(qos: .userInteractive).async {
    //                    player.skip(forwards: true)
    //                }
    //
    //            }, label: {
    //                Image(systemName: "gobackward.15")
    ////                    .foregroundColor(.black)
    //            })
    //            .font(.title)
    ////            .foregroundColor(Color.black)
    //            Spacer()
            
            
        })
    }
    
//        .foregroundColor(.black)
}




struct PlayerControlButtons: View {
    @StateObject var player: AVEnginePlayerModel
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            HStack {
                Text("speed")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            Picker(selection: $player.playbackRateIndex, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                ForEach(0..<player.allPlaybackRates.count) {
                    Text(player.allPlaybackRates[$0].label)
                }
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 20)
            
            
            HStack {
                Text("Pitch adjustment")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
            }
            Picker(selection: $player.playbackPitchIndex, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                ForEach(player.allPlaybackPitches.indices, id: \.self) { i in
                    Text(player.allPlaybackPitches[i].label)
                }
            })
            //            .listStyle(PlainListStyle())
            .pickerStyle(SegmentedPickerStyle())
            //            pickerStyle()
            
        })
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.systemGroupedBackground))
//                .blur(radius: 10)
                .opacity(0.5))
    }
    
}

struct VolumeSlider: UIViewRepresentable {
   func makeUIView(context: Context) -> MPVolumeView {
      MPVolumeView(frame: .zero)
   }

   func updateUIView(_ view: MPVolumeView, context: Context) {}
}



struct MyCustomButtonS: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            
        }
        return  Image(systemName: "stop")
    }
}

struct MyCustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let percent = Int(configuration.fractionCompleted! * 100)
        return  Text("Task \(percent)% Complete")
    }
}


// 预览
struct VoicePlayerView_Previews: PreviewProvider {
    static var c = MusicItemPlayerController()
    static var p = AVEnginePlayerModel(c)
    static var previews: some View {
//        if #available(iOS 15.0, *) {
            VoicePlayerDetailView(player: p)
//                .previewInterfaceOrientation(.portrait)
//        } else {
            // Fallback on earlier versions
//        }
    }
}
