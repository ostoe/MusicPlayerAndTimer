//
//  CircleImage.swift
//  timer
//
//  Created by linhai on 2021/5/18.
//

import SwiftUI

struct CirclePointView: View {
    var width: CGFloat = 20
    var heigth: CGFloat = 20
    var scale: CGFloat = 1
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: width, height: heigth, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .shadow(color: .gray, radius: 16, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
                .scaleEffect(scale)
                
                .padding()
//            Path {  path in
//                path.addArc(center: .init(x: width, y: heigth)  , radius: width/2, startAngle: .zero, endAngle: .init(degrees: 360), clockwise: true)
//            }
//            .stroke(Color(red: 0, green: 191, blue: 255), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
//            .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            .shadow(color: .init(red: 0, green: 191, blue: 255), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
//            Path {  path in
//                path.addArc(center: .init(x: width, y: heigth)  , radius: width, startAngle: .zero, endAngle: .init(degrees: 360), clockwise: true)
//            }
//            .stroke(Color(red: 0, green: 191, blue: 255), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
//            .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            .shadow(color: .init(red: 0, green: 191, blue: 255), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
//            .padding()
            
        }
//        .padding()
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CirclePointView()
    }
}
