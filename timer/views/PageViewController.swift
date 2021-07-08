//
//  PageViewController.swift
//  timer
//
//  Created by linhai on 2021/6/25.
//


import SwiftUI

import UIKit
import MediaPlayer

// PageViewController



struct PageViewController<Page: View> : UIViewControllerRepresentable {
    
    
    var pages: [Page]
    @Binding var currentPage: Int
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        
        return pageViewController
        
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]], direction: .forward, animated: true
        )
    }

    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        var controllers = [UIViewController]()
        
        init(_ pageViewController: PageViewController) {
            parent = pageViewController
            controllers = parent.pages.map({ rootView in
                // UIHostingController(rootView: $0  )
                UIHostingController(rootView: rootView)
            })
        }
        
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else { return nil }
//            print("before: \(index)")
            return controllers[index == 0 ? controllers.count - 1 : index - 1]
//            return (index == 0 ? controllers.last : controllers[index - 1])
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else { return nil }
//            print("after: \(index)")
            return controllers[index == controllers.count - 1 ? 0 : index + 1]
//            return (index == controllers.count - 1 ? controllers.first : controllers[index + 1])
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
//                print("datasource \(index)")
                parent.currentPage = index
            }
        }
        

    }
    
}
