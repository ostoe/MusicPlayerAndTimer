//
//  ContentView.swift
//  timer
//
//  Created by linhai on 2021/5/17.
//

import SwiftUI
import SwiftUIX

enum Page {
    case music
    case record
    case timer
    case account
}

struct MainView: View {
    
    
    //    @State var minuteInit: String = "45"
    //    @StateObject var timer: TimerData
    @EnvironmentObject var timer: TimerData
    //    @State var timeMin: Minute = Minute()
    @EnvironmentObject var timerTasks: CTimerTask
    //    @State var play: String
    @State var buttt: String = "play.fill"
    @State var buttt1: String = "play.fill"
    @State var isPresented = false
    @State private var selectedTab: Page = .music
    //    @StateObject var viewRouter = ViewRouter()
    var ag: AGAudioRecorder = AGAudioRecorder(withFileName: "re")
    
    @State var searchContent = "花海"
    @State var isEditing = false
    @StateObject var player : AVEnginePlayerModel
    @StateObject var musicItemConroller: MusicItemPlayerController
    
    @State var showPlsyDetail = false
    @StateObject var scrollViewOffsetValue = ScrollOffsetModel()
//    @State var listOffset: CGFloat = 0
    var body: some View {
        
        GeometryReader { geometry in
            
            TabView(selection: $selectedTab,
                    content:  {
                        
                        ZStack {
                            NavigationView(content: {
                                ScrollView {
                                    
                                    NavigationLink(
                                        destination: Text("LargePageView"),
                                        label: {
                                            LargePageView(musicItem: musicItemConroller).frame(width:  380, height: 160)
                                            //                                            .aspectRatio(2 / 2, contentMode: .fill)
                                            //                                            .listRowInsets(EdgeInsets())
                                        })
                                    SearchBar("search01", text: $searchContent, isEditing: $isEditing) {
                                        print("search")
                                    }
                                    .frame(height: 40 )
                                    .padding([.leading, .trailing, .bottom], 10)
                                    
                                    NavigationLink(destination: EmptyView()) {
                                        EmptyView()
                                    }
                                    musicCatelog
                                }
                                .listStyle(DefaultListStyle())
                                .navigationTitle("资料库")
                            })
                            .ignoresSafeArea( edges: .all)
                            .navigationViewStyle(StackNavigationViewStyle())
                            
                            VStack {
                                Spacer()
                                ZStack {
                                    VisualEffectBlurView()
                                        .frame(width: geometry.size.width, height: geometry.size.height/13 )
                                    //                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: nil, content: {
                                        // foot music
                                        if selectedTab == .music {
                                            MusicFootView(musicItemConroller: musicItemConroller, player: player)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    self.showPlsyDetail = true
                                                    if self.player.isPlaying {
                                                        self.player.connectVolumeTap()
                                                    }
                                                    //                                    print("all tap")
                                                }
                                                .fullScreenCover(isPresented: $showPlsyDetail, onDismiss: nil) {
                                                    VoicePlayerDetailView(player: player)
                                                }
                                        }
                                    })
                                }
                            }
                        }.tabItem {
//                            Image(systemName: "music.note")
//                            Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/)
                            Label("music", systemImage: "music.note")
//                                .foregroundColor(selectedTab == .music ? Color(.red) : .gray )
                        }
                        .tag(Page.music)
                        
                        
                        
                        Text("Tab Content 2").tabItem {
                            Label("record", systemImage: "waveform")
                        }
                        .tag(Page.record)
                        
                        TimerCollectionView(timer: _timer, timerTasks: _timerTasks)
                            .tabItem {
                                Label("timer", systemImage: "timer")
                            }
                            .tag(Page.timer)
                        
                        TimerCollectionView(timer: _timer, timerTasks: _timerTasks)
                            .tabItem {
                                Label("account", systemImage: "person.fill.viewfinder")
                            }
                            .tag(Page.account)
                        
                    })
//                .onAppear() {
//                            UITabBar.appearance().backgroundColor = .red
//                        }
                .accentColor(Color.pink)
        }
    }
    
    
    
    
    var musicCatelog: some View {
        
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, content: {
//            List {
//            // 歌曲列表
            NavigationLink(destination:
                            SongListView(musicItemController: musicItemConroller, player: player, scrollViewOffset: scrollViewOffsetValue)
            ) {
                HStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Image(systemName: "music.note")
                        .frame(width: 40, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text("歌曲")
                    Spacer()
                })
                .animation(.none)
                .font(.title3)
                .foregroundColor(.red)
            }
            .padding(0.5)
            //                                            .hiddenNavigationBarStyle()
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 380, y: 0))
            }
            .stroke(lineWidth: 0.3)
            .opacity(0.5)
            // 播放列表
            //                ForEach(0..<20) { i in
            //                    NavigationLink("ffsfds\(i)", destination: Text("fff\(i)"))
            //                }
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }

            NavigationLink(destination:
                            Text("专辑")
            ) {
                HStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Image(systemName: "music.note.list")
                        .frame(width: 40, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text("播放列表")
                    Spacer()
                })
                .animation(.none)
                .font(.title3)
                .foregroundColor(.red)
            }
            .labelsHidden()
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 380, y: 0))
            }
            .stroke(lineWidth: 0.3)
            .opacity(0.5)
            
//            }
            
        })
        .padding([.leading], 20)
        .animation(.none)
        .listRowInsets(EdgeInsets())
        
        //        })
        //        .hiddenNavigationBarStyle()
        //                                    .navigationBarTitle("")
        //                                    .navigationBarHidden(true)
    }
}


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style = .systemUltraThinMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}



struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {
        
    }
    
}


struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}





class ViewRouter: ObservableObject {
    @Published var currentPage: Page  = .music
}



struct HomeTabBarIcon: View {
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    let width, height: CGFloat
    let systemIconName, tabName: String
    var body: some View {
        VStack {
            Image(systemName: systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .padding(.top, 10)
            Text(tabName)
                .font(.footnote)
            //            Spacer()
        }
        .padding(.horizontal, -4) // ?
        .contentShape(Rectangle())
        .onTapGesture {
            viewRouter.currentPage = assignedPage
        }
        .foregroundColor(viewRouter.currentPage == assignedPage ? .red : .gray)
    }
}




struct ContentView_Previews: PreviewProvider {
    static let tc = CTimerTask()
    static let t = TimerData(15, 0, 0, tc)
    static let musicController = MusicItemPlayerController()
    static let player = AVEnginePlayerModel(musicController)
    static var previews: some View {
        //        ContentView(timer: t).environmentObject(t)
        MainView(player: player, musicItemConroller: musicController).environmentObject(t).environmentObject(tc)
    }
}


