//
//  PageControl.swift
//  timer
//
//  Created by linhai on 2021/6/27.
//


import SwiftUI
import UIKit


struct PageControl: UIViewRepresentable {
    var numberOfPage: Int
    @Binding var currentPage: Int
    
    // 最先运行,
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPage
        control.addTarget(
            context.coordinator,
            // 添加函数，使得变化的时候调用Coordinator的更新函数，也就是更新bing的值返回给swiftui中的值。不更新uiview
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)
        
        return control
    }
    
    // 更新uiview，不更新bingding 的 currentPage
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
   
    class Coordinator: NSObject {
        var control: PageControl
        
        init(_ control: PageControl) {
            self.control = control
        }
        
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            // 由于 control.currentPage 就是上面的currentpage，实际上调用这个函数back to swiftui中的currentPage值
            control.currentPage = sender.currentPage
        }
    }
    
}


