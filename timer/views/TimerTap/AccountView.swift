//
//  AccountView.swift
//  timer
//
//  Created by linhai on 2021/7/13.
//

import SwiftUI

struct AccountView: View {
    @Binding var progressBinding: Double
    
    @State 
    //    @State var offset: CGFloat = 0
    var progressShow: Double
    @State var tapScale: Double = 1.0
    var f: Optional<(Double) -> Void>
    var paddingValue: CGFloat = 40
    var circleRadius: CGFloat = 10
    var trackHeight: CGFloat = 5
    var shadowRadius: CGFloat = 5
    var circleEdgeLineWidth: CGFloat = 4
    @State var size: CGFloat = 0.5
    @State var isShowPopup = false
    var body: some View {
        VStack {
//            let animation = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: false)
            let animation = Animation.linear(duration: 1.0).repeatForever(autoreverses: true)
            Image(systemName: "arrow.down.circle")
                .scaleEffect(size)
//                .rotationEffect(Angle(degrees: size))
                .onAppear(perform: {
                    withAnimation(animation) {
                        self.size = 1.3
                    }
                })
//                .popup(isPresented: $isShowPopup,type: .default, position: .top, animation: .easeInOut, autohideIn: 1.5, closeOnTap: true, closeOnTapOutside: true, view: {Text("pop").foregroundColor(Color.blue)})
            
            Button(action: {isShowPopup.toggle()}, label: Text("Button"))
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                let scale = UIScreen.main.bounds.width - 2 * paddingValue
                Capsule()
                    .fill(.black.opacity(0.25))
                    .frame(height: trackHeight)
                Capsule()
                    .fill(Color.pink)
                    .frame(width: progressShow * scale, height: trackHeight)
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: circleRadius*2, height: circleRadius*2)
                    .shadow(radius: 5)
                
                    .background(Circle().stroke(Color.systemPink.opacity(0.25), lineWidth: circleEdgeLineWidth))
                    .offset(x: progressShow * scale - circleRadius + circleEdgeLineWidth * 0 / 2)
                    .gesture(DragGesture().onChanged({ value in
                        //                    print("\(value.location.x)")
                        tapScale = 1.3
                        if value.location.x >= 0 && value.location.x <= scale {
                            $progressBinding.wrappedValue = value.location.x / scale
                            //                        print("\(progressShow)")
                        } else if value.location.x < 0 {
                            $progressBinding.wrappedValue = 0
                        } else if value.location.x > scale {
                            $progressBinding.wrappedValue = 1.0
                        }
                    }).onEnded({ value in
                        tapScale = 1.0
                        if let f = f {
                            f(progressShow)
                        }
                    })
                             
                    )
            }
            .padding([.leading, .trailing], paddingValue)
        }
    }
}


struct CustomProgressWithBuffer: View {
    @Binding var progressBinding: Double
    //    @State var offset: CGFloat = 0
    var progressShow: Double
    var bufferProgressShow: Double
    @State var tapScale: Double = 1.0
    var f:  (Double) -> Void
    var paddingValue: CGFloat = 32
    var circleRadius: CGFloat = 8
    var trackHeight: CGFloat = 4
    var shadowRadius: CGFloat = 5
    var circleEdgeLineWidth: CGFloat = 4
    @State var isShowPopup = false
    var body: some View {
//        VStack {
//
//                .popup(isPresented: $isShowPopup,type: .default, position: .top, animation: .easeInOut, autohideIn: 1.5, closeOnTap: true, closeOnTapOutside: true, view: {Text("pop").foregroundColor(Color.blue)})
    
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                let scale = UIScreen.main.bounds.width - 2 * paddingValue
                Group {
                Capsule()
                    .fill(.gray.opacity(0.25))
                    .frame(height: trackHeight)
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: bufferProgressShow * scale, height: trackHeight)
                    
                Capsule()
                    .fill(Color.pink)
                    .frame(width: progressShow * scale, height: trackHeight)
                }
                Circle()
                    .fill(Color.white.opacity(1.0))
                    .frame(width: circleRadius*2, height: circleRadius*2)
                    .shadow(radius: 5)
                    .scaleEffect(tapScale)
//                    .background(.white)
//                    .background(Circle().stroke(Color.systemPink.opacity(0.25), lineWidth: circleEdgeLineWidth))
                    .offset(x: progressShow * scale - circleRadius + circleEdgeLineWidth * 0 / 2)
                    .gesture(DragGesture().onChanged({ value in
                        //                    print("\(value.location.x)")
                        self.tapScale = 1.3
                        if value.location.x >= 0 && value.location.x <= scale {
                            $progressBinding.wrappedValue = value.location.x / scale
                            //                        print("\(progressShow)")
                        } else if value.location.x < 0 {
                            $progressBinding.wrappedValue = 0
                        } else if value.location.x > scale {
                            $progressBinding.wrappedValue = 1.0
                        }
                    }).onEnded({ value in
                        self.tapScale = 1.0
                        f(progressShow)
                    })
                             
                    )
            }
            .padding([.leading, .trailing], paddingValue)
        
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(progressBinding: .constant(0), progressShow: 0, f: nil)
    }
}
