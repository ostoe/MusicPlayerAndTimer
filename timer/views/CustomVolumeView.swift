//
//  VolumeView.swift
//  timer
//
//  Created by linhai on 2021/6/30.
//

import SwiftUI
import UIKit
import MediaPlayer


struct CustomVolumeView: UIViewRepresentable {
    
//    var uiSlider: UISlider?
    @Binding var volume: Float
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateVolume(_ f: Float) {
        volume = f
        let uiSlider = MPVolumeView().subviews.first(where: { $0 is UISlider }) as? UISlider
        uiSlider?.setValue(f, animated: true)
    }
    
    func makeUIView(context: Context) -> MPVolumeView {
        let mpVolume = MPVolumeView()
//        mpVolume.showsVolumeSlider = false
//        mpVolume.volumeWarningSliderImage = UIImage(systemName: "speaker.wave.3")
        mpVolume.setVolumeThumbImage(UIImage(named: "volume"), for: .normal)
        let uiSlider = mpVolume.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        uiSlider?.addTarget(context.coordinator, action: #selector(Coordinator.updateVolume(sender:)), for: .valueChanged)
        return mpVolume
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        let uiSlider = uiView.subviews.first(where: { $0 is UISlider }) as? UISlider
        uiSlider?.setValue(volume, animated: true)
    }
    
    class Coordinator: NSObject {
        var parent: CustomVolumeView
        init(_ parent: CustomVolumeView) {
            self.parent = parent
        }
        
        @objc func updateVolume(sender: UISlider) {
                    print(#function)
//            print("sender: \(sender.value)")
                    parent.volume = sender.value
//                    print(parent.volume)
        }
    }
}
