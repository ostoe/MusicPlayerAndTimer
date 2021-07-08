//
//  TimerCollectionView.swift
//  timer
//
//  Created by linhai on 2021/6/23.
//

import SwiftUI


struct TimerCollectionView: View {
    @EnvironmentObject var timer: TimerData
    //    @State var timeMin: Minute = Minute()
    @EnvironmentObject var timerTasks: CTimerTask
    //    @State var play: String
    @State var buttt: String = "play.fill"
    @State var buttt1: String = "play.fill"
    @State var isPresented = false
    var ag: AGAudioRecorder = AGAudioRecorder(withFileName: "re")
    
    var body: some View {
        NavigationView {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                
//                Button(action: {
//                    DispatchQueue.main.async {
//                        if buttt == "play.fill" {
//                            buttt = "stop.fill"
//                            //                        DispatchQueue.global(qos: .userInteractive).async {
//                            self.ag.doRecord()
//                            //                        audioManager.checkRecordPermission()
//                            //                        audioManager.recordStart()
//                            //                        }
//                        } else {
//                            buttt = "play.fill"
//                            //                        DispatchQueue.global(qos: .userInteractive).async {
//                            self.ag.doStopRecording()
//                            //                        audioManager.stopRecording()
//                            //                        }
//                        }
//                    }
//                    
//                }) {
//                    Image(systemName: buttt)
//                }.scaleEffect(4)
//                
//                Button(action: {
//                    DispatchQueue.main.async {
//                        if buttt1 == "play.fill" {
//                            buttt1 = "stop.fill"
//                            self.ag.doPlay()
//                        } else {
//                            buttt1 = "play.fill"
//                            self.ag.doPause()
//                        }
//                    }
//                }) {
//                    Image(systemName: buttt1)
//                }
                
                //            Spacer()
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 28, content: {
                    //                Text(timer.minutes.timeUnit)
                    //                    .font(.title)
                    //                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    //                    .animation(.spring())
                    TimeUnitView(timeUnit: timer.hours.timeUnit, updateTime: $timer.hours.timeUnit, maxLimite: timer.hours.maxLimite, unit: "时")
                        .scaleEffect(0.7)
                    
                    TimeUnitView(timeUnit: timer.minutes.timeUnit, updateTime: $timer.minutes.timeUnit, maxLimite: timer.minutes.maxLimite, unit: "分")
                    
                    TimeUnitView(timeUnit: timer.seconds.timeUnit, updateTime: $timer.seconds.timeUnit, maxLimite: timer.seconds.maxLimite, unit: "秒")
                        .scaleEffect(0.7)
                    
                    Text(String(timer.milliSeconds))
                        .foregroundColor(.red)
                        .underline(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, color: .red)
                        //                    .bold()
                        .frame(width: 10, height: 10, alignment: .trailing)
                        .offset(x: -5, y: 26)
                    
                })
                .padding(EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 20))
                .offset(x: 27, y: 0)
                
                ZStack {
                    TimerCircleView(minute2angle: timer.minutes.timeUnit, minute: $timer.minutes.timeUnit)
                    HStack {
                        Button(action: {
                            //                        if self.play == "play.fill" {
                            //                            self.play = "stop.fill"
                            //
                            //                        } else {
                            //                            self.play = "play.fill"
                            //                        }
                            self.timer.toggle()
                        })
                        {
                            Image(systemName: timer.toggleButtonState)
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .scaleEffect(3)
                                .animation(.interactiveSpring())
                        }
                    }
                }
                .padding()
                //            navigationBarTitle(Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/))
                
                //            Button(action: {}) {
                NavigationLink(destination: TaskListView(cTask: $timerTasks.taskList, selectColor: timerTasks.selectIndex, selectColorBinding: $timerTasks.selectIndex)) {
                    
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                            RoundedRectangle(cornerRadius: 12, style: .circular)
                                .foregroundColor(.blue)
                                //init(.sRGB, red: 51/255, green: 153/255, blue: 204/255, opacity: 0.9)
                                .blur(radius: 0.5)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                .opacity(0.9)
                                .frame(width: 300, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            //                            Rectangle()
                            //                                .foregroundColor(.gray)
                            //                                .opacity(0.3)
                            //                                .cornerRadius(8)
                            //                                .background(
                            //                                    RoundedRectangle(cornerRadius: 5)
                            //                                        .stroke(Color.green,lineWidth: 2)
                            //                                )
                            Text("结束后： \(self.timerTasks.taskList[Int(self.timerTasks.selectIndex)].display)")
                                .foregroundColor(.white)
                                .bold()
                                .font(.title2)
                            
                            
                        })
                        
                        //                            .padding(.)
                        //                        Image(systemName:"list.dash")
                        
                    })
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    .font(.largeTitle)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.green,lineWidth: 0)
                    )
                    
                }
                ////            }
                //            }
                //            .navigationTitle("Landmarks")
                ////            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
                //            .navigationTitle("a")
                //            .padding(.bottom)
                //            Spacer()
                
                
            })
            .padding()
            
        }
    }
    
}


struct TimerCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        TimerCollectionView()
    }
}
