//
//  TimeUnitView.swift
//  timer
//
//  Created by linhai on 2021/5/24.
//

import SwiftUI


struct TimeUnitView: View {
    var timeUnit: Double
    @Binding var updateTime: Double
    var maxLimite: Int
//    @Binding var minute111: TimeUnit
    var unit: String
    var body: some View {
        HStack(alignment: .center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/1, content: {
            VStack(alignment: .center, spacing: nil, content: {
//                Button(action: {
//
//                }
//                ){
//                Image(systemName: "plus.app")
//                    .scaleEffect(2)
//
//                }
                Button(action: {
                    //                    self.timeUnit = "20"
//                    let t1 = Int(self.$updateTime.wrappedValue) ?? 0
                    if (Int(floor(self.$updateTime.wrappedValue)) < maxLimite) {
                        self.updateTime = self.$updateTime.wrappedValue + 1
                        //                        self.timeUnit  = String(t1 + 1)
                    }
                }, label: {
                    Text("  +  ")
                        .bold()
                        .font(.title)
                        .foregroundColor(.blue)
                        .background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0))
                        .cornerRadius(12)
                        .frame(width: 40, height: 40, alignment: .center)
                        
                })
                Text(String(Int(floor(self.timeUnit))))
                    .font(.title)
                    .foregroundColor(.blue)
                    .animation(.spring())
                //                    .transition(.moveAndFade)
                
                Button(action: {
                    //                    self.timeUnit = "20"
//                    let t1 = self.$updateTime.wrappedValue) ?? 0
                    if (self.$updateTime.wrappedValue > 0) {
                        self.updateTime = self.$updateTime.wrappedValue - 1
                        //                        self.timeUnit  = String(t1 - 1)
                    }
                }, label: {
                    Text("  -  ")
                        .bold()
                        .font(.title)
                        .foregroundColor(.blue)
                        .background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0))
                        .cornerRadius(12)
                        .frame(width: 40, height: 40, alignment: .center)
                })
            })
            .opacity(1)
            Text(unit)
                .font(.title)
                .foregroundColor(.blue)
                .opacity(1)
            //                .padding()
        })
        .frame(width: 80, height: 120, alignment: .center)
        .padding(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: -30))

    }
}

struct TimeUnitView_Previews: PreviewProvider {
    static var previews: some View {
        TimeUnitView(timeUnit: 45, updateTime: .constant(45), maxLimite: 60, unit: "分")
    }
}
