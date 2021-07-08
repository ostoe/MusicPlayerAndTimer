//
//  TaskList.swift
//  timer
//
//  Created by linhai on 2021/6/1.
//

import SwiftUI

struct TaskListView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var cTask: [STimerTask]
    
     var selectColor: UInt
    @Binding var selectColorBinding: UInt
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .center, spacing: nil, content: {
                Text("")
                    .padding(.vertical)
                Spacer()
    //            Text(String(self.selectColor))
    //                .font(.caption)
//                let r: Int = cTask.count
                ForEach(self.cTask) { ctk in
                    HStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        
                        Button(action: {
                            self.selectColorBinding = UInt(ctk.id)
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Spacer()
                                Text(ctk.title)
                                    .font(.title3)
                                    .bold()
                                    .padding()
                            Spacer()
                        })
                        
            //                Text(self.cTask.taskList[i].display) self.navigationController?.popViewController(animated: true)
                        
                    })
                    
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.green,lineWidth:
                                        self.selectColor == UInt(ctk.id) ?
                                            2.0 : 0.0)
                    )
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                }
//                .padding()
//                List(self.cTask.indices, id: \.self) { i in
//
//
//                }

            })
    //
    //        .padding()
    //        Spacer()
        }
//        .navigationBarHidden(true)
        // 隐藏返回按键
//        .navigationBarBackButtonHidden(true)
        
 
    }
    
}

struct TaskList_Previews: PreviewProvider {
    static var a = CTimerTask()
    static var previews: some View {
        TaskListView(cTask: .constant(a.taskList), selectColor: a.selectIndex, selectColorBinding: .constant(a.selectIndex))
//        TaskList(cTask: .constant(a), selectColor: a.selectIndex)
    }
}
