//
//  DownloadListView.swift
//  timer
//
//  Created by linhai on 2021/7/13.
//

import SwiftUI
import SwiftUIX

struct DownloadListView: View {
    @State var isShowPopUpView = false
    @State var popoverSize = CGSize(width: 300, height: 200)
    @StateObject var player : AVEnginePlayerModel
    @StateObject var musicItemController: MusicItemPlayerController
    @State var searchContent: String = ""
    @State var isSearching: Bool = false
    @State var isEditing: Bool = false
    @State var downloadUrl: String = "https://www.fesliyanstudios.com/musicfiles/2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com/15SecVersion2019-04-23_-_Trusted_Advertising_-_www.fesliyanstudios.com.mp3"
    @State var musicTitle: String = "~~~"
    @State var notificationContent: String = "重复下载，测试需要先删除"
    @State var isShowNotification = false
    var body: some View {
        
        VStack(alignment: .center, spacing: nil)
        {
            
            HStack{
//                Spacer()
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text(searchContent)
                        .frame(width: 300)
                }
                .padding([.leading, .trailing], 10)
                .padding([.bottom, .top], 8)
                .background(RoundedRectangle(cornerRadius: 8, style: .circular)
                                .foregroundColor(.gray.opacity(0.13))
                                )
                .onTapGesture {
                    isSearching.toggle()
                }
                .popover(isPresented: $isSearching) {
                    VStack {
                        CustomSearchBarFromUIX("---!", text: $searchContent, isEditing: $isEditing, onCommit: {
                            print("tosearch commit \(searchContent)")
                        }, beginAutoFocusd: true)
                            .showsCancelButton(isEditing)
                    
//                    .onCancel {
//                        self.isEditing = false
//                    }
                    
                        Spacer()
                    }

                }
                .onDisappear {
                    self.isSearching = false
                }
                
                Button(action: {
                    self.player.testRemoveAllDownloadListfile(notificationHandle: { content in
                        self.notificationContent = content
                        self.isShowNotification.toggle()}
                    )
                }, label: {
                    Text("RESET")
                        .foregroundColor(.pink)
                        .font(.title)
                })

//                Spacer()
                WithPopover(showPopover: $isShowPopUpView, popoverSize: popoverSize) {
                    Button(action: {
                        isShowPopUpView.toggle()
                    }, label:
                            Image(systemName: "plus")
//                            .scaledToFit()
                            .foregroundColor(.black.opacity(0.8))
                            .frame(width: 40, height: 40)
//                            .padding()
                    )
                } popoverContent: {
                    VStack {
                        TextField("歌曲名称", text: $musicTitle)
                            .font(.title3)
                            .textFieldStyle(.plain)
                        TextField("http://...", text: $downloadUrl)
                            .font(.title3)
                            .textFieldStyle(.plain)
                        Spacer()
                        HStack(spacing: 5) {
                            Spacer()
                            Button(action: {
                                isShowPopUpView.toggle()
                                player.handlePlayStreamURL(surl: downloadUrl, musicTitle: musicTitle, notificationHandle: {content in
                                    self.notificationContent = content
                                    self.isShowNotification.toggle()})
                            }, label: Text("Play").font(.title2).background(RoundedRectangle(cornerRadius: 5).stroke(Color.systemPink, lineWidth: 2)))
                            Spacer()
                            Button(action: {isShowPopUpView.toggle();
                                player.handleDownloadStreamURL(surl: downloadUrl, musicTitle: musicTitle, complateHandle: {
                                    // todo update progress or states
                                }, notificationHandle: {content in
                                    self.notificationContent = content
                                    self.isShowNotification.toggle()})
                            }, label: Text("Download").font(.title2).background(RoundedRectangle(cornerRadius: 5).stroke(Color.systemPink, lineWidth: 2)))
                            Spacer()
                        }
                    }
                    .padding([.all], 10)
                    
                }
                
                
            }
            ProgressView(value: player.downloadProgress)
            ScrollView {
                ScrollViewReader { proxy in
//                    ZStack {
                        LazyVStack {
                            ForEach(0..<musicItemController.downloadList.list.count, id: \.self) { i in
                                //                                if musicItemController.downloadList[i].loc == .remote {
                                downloafLineContenView(musicItemController: musicItemController, player: player, i: i)
                                    .padding([.leading, .trailing], 8)
                                    .padding([.top], 3)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // todo handle the caching
                                        if self.musicItemController.currentIndex == i && self.musicItemController.collectionIndex == 1 {
                                            self.player.playOrPause(false)
                                        } else {
                                            self.musicItemController.prepareToNextItem(i, collectionIndex: 1)
                                            self.player.nextItem(false)
                                        }
                                    }
                                //                                }
                                
                            }
                            
                        }
//                        .popup(isPresented: <#T##Binding<Bool>#>, type: ., position: <#T##Popup<View>.Position#>, animation: <#T##Animation#>, autohideIn: <#T##Double?#>, dragToDismiss: <#T##Bool#>, closeOnTap: <#T##Bool#>, closeOnTapOutside: <#T##Bool#>, dismissCallback: <#T##() -> ()#>, view: <#T##() -> View#>)
                        .popup(isPresented: $isShowNotification, autohideIn: 1.5, closeOnTap: true, closeOnTapOutside: true) {
                            Text("\(notificationContent)\(musicTitle)")
                                .frame(width: 300, height: 80)
                                                .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                                                .cornerRadius(30.0)
                        }
                        
//                    }
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct downloafLineContenView: View {
    @StateObject var musicItemController: MusicItemPlayerController
    @StateObject var player: AVEnginePlayerModel
    @State var size: CGFloat = 0.5
    @State var rotation: CGFloat = 0
    var i: Int
    let scaleAnimation = Animation.linear(duration: 1.0).repeatForever()
    let rotationAnimation = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    var body: some View {
        if i < musicItemController.downloadList.list.count {
        HStack(alignment: .center, spacing: 5, content: {
            Text("\(i+1)")
                .font(.system(.caption2, design: .monospaced))
                .bold()
            //                .opacity(0.8)
                .foregroundColor(.gray)
                .frame(width: 22, height: 20)
            // musicItemController.downloadList.list[i].loc != .cache &&
            if musicItemController.collectionIndex == 1 {
                if  musicItemController.currentIndex == i {
                    Image(systemName: player.isPlaying ? "pause":"play")
                }
            }
            if let artwork = musicItemController.downloadList.list[i].mediaInfo?.artwork {
                Image(uiImage: (artwork.image(at: CGSize(width: 40, height: 40)))! )
                    .resizable()
                    .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            } else {
                Image("iphone02")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
            VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text(musicItemController.downloadList.list[i].mediaInfo?.title ?? "")
                    .font(.custom("title", size: 17))
                    .lineLimit(1)
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 2, content: {
                    Image(systemName: "heart.fill")
                    Text(musicItemController.downloadList.list[i].mediaInfo?.artist ?? "")
                        .font(.custom("title", size: 13))
                        .lineLimit(1)
                        .foregroundColor(.gray)
                    Text(musicItemController.downloadList.list[i].mediaInfo?.albumTitle ?? "")
                        .font(.custom("title", size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                })
                
            })
            
            Spacer()
            
            if musicItemController.downloadList.list[i].loc != .disk {
                if musicItemController.downloadList.list[i].downloadState == .downloading {
                    Image(systemName: "arrow.down.circle") // donw done! "chevron.down.circle"
                        .scaleEffect(size)
                        .onAppear(perform: {
                            // todo if down complate
                            withAnimation(scaleAnimation) {
                                self.size = 1.3
                            }
                        })
                } else if musicItemController.downloadList.list[i].downloadState == .buffering {
//                    Image(systemName: "circle.dashed") // donw done! "chevron.down.circle"
                    Image(systemName: "icloud.and.arrow.down")
                        .rotationEffect(Angle(degrees: rotation))
                        .onAppear(perform: {
                            // todo if down complate
//                            withAnimation(rotationAnimation) {
//                                self.rotation = 360
//                            }
                        })
                }
            } else {
                Image(systemName: "chevron.down.circle.fill")
            }
            
            // line list ellipsis.circle
            
            Image(systemName: "ellipsis")
                .rotationEffect(Angle(degrees: 90))
                .scaleEffect(1.0)
            //                .padding([ .trailing], 10)
        })
        }
        
    }
}



//CustomSearchBar(text: $viewModel.searchTerm,
//           onSearchButtonClicked: viewModel.onSearchTapped)

struct CustomSearchBar: UIViewRepresentable {
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.becomeFirstResponder()
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    

    @Binding var text: String
    var onSearchButtonClicked: (() -> Void)? = nil

    class Coordinator: NSObject, UISearchBarDelegate {

        let control: CustomSearchBar

        init(_ control: CustomSearchBar) {
            self.control = control
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            control.text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            control.onSearchButtonClicked?()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    

}

struct DownloadListView_Previews: PreviewProvider {
    
    
    static let musicItemController = MusicItemPlayerController()
    static let player =  AVEnginePlayerModel(musicItemController)
    static let offset = ScrollOffsetModel()
    static var previews: some View {
        DownloadListView(player: player, musicItemController: musicItemController)
    }
    
}
