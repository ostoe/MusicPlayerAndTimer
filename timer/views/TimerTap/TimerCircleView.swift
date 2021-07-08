//
//  TimerCircle.swift
//  timer
//
//  Created by linhai on 2021/5/21.
//

import SwiftUI


struct TimerCircleView: View {
    var minute2angle: Double
//    @State var minute: String = String(Int(round(231 / 6)))
    @Binding var minute: Double
    let pi = Double.pi;
    let radius = 130.0
    let lineWidth = 3.0
    let pointradius = 16.0
    let centPoint = CGPoint(x: 130+1.5, y: 130 + 1.5)
    @State var offset: CGPoint = CGPoint(x:  130 + 1.5, y: 1.5)
//    @State var offset: CGPoint = CGPoint(x: 0, y:0)
//    @State var offset: CGSize = .zero
    @State var rectPosition = CGPoint(x: 50, y: 50)

    
    func getOffset(angle: Double, radius: Double, lineWidth: Double, pointradius: Double) -> CGPoint {
        let offset_x = radius * cos(angle * Double.pi/180) + radius + lineWidth / 2
        let offset_y = radius * sin(angle * Double.pi/180) + radius + lineWidth / 2 
        return CGPoint(x: offset_x, y: offset_y)
//        return CGSize(width: 130+1.5-8, height: 8)
    }
    
    func getMoveOffset(value: DragGesture.Value, centerPoint: CGPoint, radius: Double, lineWidth: Double, pointradius: Double)  {
        let dstPoint: CGPoint = value.location
        let xs: Double = Double(dstPoint.x - centerPoint.x)
        let ys: Double = Double(dstPoint.y - centerPoint.y)
        let absDistance: Double = Double(sqrt(pow(xs, 2) + pow(ys, 2)))
//        let offsetX = radius * xs / absDistance + radius
//        let offsetY = radius * ys / absDistance + radius
        // angle
        let angle: Double
        let xAngle = abs(asin(xs/absDistance)*180/Double.pi)
        if xs > 0 {
            if ys >= 0 {
                angle = 180 - xAngle
            } else {
                angle = xAngle
            }
        } else {
            if ys >= 0 {
                angle = xAngle + 180
            } else {
                angle = 360 - xAngle
            }
        }
//        print(xAngle)
        self.minute = angle/6
//        minute.updateMinute(m: s)
//        self.minute = "100"
//        return (CGPoint(x: offsetX, y: offsetY))
    }
    
    var body: some View {
        let drapGesture = DragGesture()
            .onChanged{
                (value) in
//                print(value.startLocation, value.location, value.translation)
               getMoveOffset(value: value, centerPoint: centPoint, radius: radius, lineWidth: lineWidth, pointradius: pointradius)
//                self.offset = value.translation
                
            }
            .onEnded{ (value) in
                
//                print(value.startLocation, value.location, value.translation)
                getMoveOffset(value: value, centerPoint: centPoint, radius: radius, lineWidth: lineWidth, pointradius: pointradius)
//                self.offset = value.translation
            }
        
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            
//            TextView1(text: minute)
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top), content: {
            //            CircleImage()
            //                .position(rectPosition)
                        
                        
                        Path { path in
            // radius 是半径
                            path.addRelativeArc(center: centPoint, radius: 130, startAngle: .init(degrees: -90), delta: Angle(degrees: Double(self.minute2angle * 6)))          }
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .animation(.interactiveSpring())
                        
                        Path { path in
            // radius 是半径
                            path.addRelativeArc(center: centPoint, radius: 130+3, startAngle: .init(degrees: -90), delta: Angle(degrees: 360))
                            path.addRelativeArc(center: centPoint, radius: 130-3, startAngle: .init(degrees: -90), delta: Angle(degrees: 360))
                        }
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                        .brightness(0.3)
                        CirclePointView()
                            .position(getOffset(angle: self.minute2angle*6 - 90, radius: radius, lineWidth: lineWidth, pointradius: pointradius))
            //                .offset(offset)
                            .gesture(drapGesture)
            //                .animation(.linear)
                    })
            //        .frame()
            //        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .frame(width: CGFloat(radius)*2 + 3, height: CGFloat(radius)*2 + 3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        })
        
        
    }
}

struct TimerCircle_Previews: PreviewProvider {
    static var previews: some View {
        TimerCircleView(minute2angle: 45, minute: .constant(45))
    }
}
