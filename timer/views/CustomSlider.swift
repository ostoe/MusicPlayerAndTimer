//
//  CustomSlider.swift
//  timer
//
//  Created by linhai on 2021/7/12.
//

import Foundation
import SwiftUI
import UIKit
import SwiftUIX

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return img
    }
}


struct CustomSlider: UIViewRepresentable {
    var minTrackColor: UIColor? = .systemPink
    var maxTrackColor: UIColor? = .darkGray
    @Binding var value: Double
    var thumbColor: UIColor = .blue
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
//    UIProgressView!!!!!!!!
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
//        slider.setThumbImage(UIImage.circle(diameter: 5, color: .gray), for: [.normal, .focused, .disabled, .reserved, .selected, .application, .highlighted ])
        slider.setMaximumTrackImage(UIImage.circle(diameter: 5, color: .gray), for: [.normal, .focused, .disabled, .reserved, .selected, .application, .highlighted ])
        
        slider.setThumbImage(UIImage(systemName: "circle.dashed"), for: [.normal, .focused, .disabled, .reserved, .selected, .application, .highlighted ])
//        slider.thumbRect(forBounds: <#T##CGRect#>, trackRect: <#T##CGRect#>, value: <#T##Float#>)
//        slider.currentThumbImage = UIImage.circle(diameter: 20, color: .gray)
        
        
//        let mask = CAGradientLayer(layer: slider.layer)
//        let lineTop = (slider.bounds.height/2 - 0.5) / slider.bounds.height
//        mask.frame = slider.bounds
//        mask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        mask.locations = [NSNumber(floatLiteral: lineTop), NSNumber(floatLiteral: lineTop)]
//        slider.layer.mask = mask
        
            slider.thumbTintColor = thumbColor
            slider.minimumTrackTintColor = minTrackColor
            slider.maximumTrackTintColor = maxTrackColor
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .allEvents)
        slider.addTarget(nil, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
//        self.value = context.coordinator.value
        uiView.value = Float(self.value)
    }
    
    final class Coordinator: NSObject {
        // The class property value is a binding: It’s a reference to the SwiftUISlider
        // value, which receives a reference to a @State variable value in ContentView.
        var parent: CustomSlider
    
        // Create the binding when you initialize the Coordinator
        init(_ parent: CustomSlider) {
          self.parent = parent
        }
    
        // Create a valueChanged(_:) action
        @objc func valueChanged(_ sender: UISlider) {
            parent.value = Double(sender.value)
        }
      }
}





struct WithPopover<Content: View, PopoverContent: View>: View {
    
    @Binding var showPopover: Bool
    var popoverSize: CGSize? = nil
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    
    var body: some View {
        content()
        .background(
            Wrapper(showPopover: $showPopover, popoverSize: popoverSize, popoverContent: popoverContent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    struct Wrapper<PopoverContent: View> : UIViewControllerRepresentable {
        
        @Binding var showPopover: Bool
        let popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                popoverContent: popoverContent) {
                    self.showPopover = false
            }
        }
        
        func updateUIViewController(_ uiViewController: WrapperViewController<PopoverContent>,
                                    context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) {
            uiViewController.updateSize(popoverSize)

            if showPopover {
                uiViewController.showPopover()
            }
            else {
                uiViewController.hidePopover()
            }
        }
    }
    
    class WrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
        
        var popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void
        
        var popoverVC: UIViewController?

        required init?(coder: NSCoder) { fatalError("") }
        init(popoverSize: CGSize?,
             popoverContent: @escaping () -> PopoverContent,
             onDismiss: @escaping() -> Void) {
            self.popoverSize = popoverSize
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            super.init(nibName: nil, bundle: nil)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.delegate = self
            }
            popoverVC = vc
            self.present(vc, animated: true, completion: nil)
        }
        
        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }
        
        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
                        return .none // this is what forces popovers on iPhone
                }
    }
}






#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

/// A specialized view for receiving search-related information from the user.
public struct CustomSearchBarFromUIX: DefaultTextInputType {
    
    @Binding fileprivate var text: String
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @ObservedObject private var keyboard = Keyboard.main
    #endif
    
    private let onEditingChanged: (Bool) -> Void
    private let onCommit: () -> Void
    private var beginAutoFocusd: Bool = false
    private var placeholder: String?
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    private var appKitOrUIKitFont: UIFont?
    private var appKitOrUIKitForegroundColor: UIColor?
    private var searchBarStyle: UISearchBar.Style = .minimal
    private var iconImageConfiguration: [UISearchBar.Icon: AppKitOrUIKitImage] = [:]
    #endif
    
    private var showsCancelButton: Bool?
    private var onCancel: () -> Void = { }
    
    var customAppKitOrUIKitClass: AppKitOrUIKitSearchBar.Type?
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    private var returnKeyType: UIReturnKeyType?
    private var enablesReturnKeyAutomatically: Bool?
    private var isSecureTextEntry: Bool = false
    private var textContentType: UITextContentType? = nil
    private var keyboardType: UIKeyboardType?
    #endif
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.placeholder = String(title)
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
        
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { },
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        beginAutoFocusd : Bool = false
    ) {
        self.init(
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
        self.beginAutoFocusd = beginAutoFocusd
    }
}

#if os(iOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension CustomSearchBarFromUIX: UIViewRepresentable {
    public typealias UIViewType = UISearchBar
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIViewType()
        
        uiView.delegate = context.coordinator
        if beginAutoFocusd {
            uiView.becomeFirstResponder()
        }
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.base = self
        
        _updateUISearchBar(uiView, environment: context.environment)
    }
    
    func _updateUISearchBar(
        _ uiView: UIViewType,
        environment: EnvironmentValues
    ) {
        style: do {
            if (appKitOrUIKitFont != nil || environment.font != nil) || appKitOrUIKitForegroundColor != nil {
                if let textField = uiView._retrieveTextField() {
                    if let font = appKitOrUIKitFont ?? environment.font?.toUIFont() {
                        textField.font = font
                    }
                    
                    if let foregroundColor = appKitOrUIKitForegroundColor {
                        textField.textColor = foregroundColor
                    }
                }
            }
            
            if let placeholder = placeholder {
                uiView.placeholder = placeholder
            }
            
            uiView.searchBarStyle = searchBarStyle
            
            for (icon, image) in iconImageConfiguration {
                if uiView.image(for: icon, state: .normal) == nil { // FIXME: This is a performance hack.
                    uiView.setImage(image, for: icon, state: .normal)
                }
            }
            
            uiView.tintColor = environment.tintColor?.toUIColor()
            
            if let showsCancelButton = showsCancelButton {
                if uiView.showsCancelButton != showsCancelButton {
                    uiView.setShowsCancelButton(showsCancelButton, animated: true)
                }
            }
        }
        
        keyboard: do {
            if let returnKeyType = returnKeyType {
                uiView.returnKeyType = returnKeyType
            } else {
                uiView.returnKeyType = .default
            }
            
            if let keyboardType = keyboardType {
                uiView.keyboardType = keyboardType
            } else {
                uiView.keyboardType = .default
            }
            
            if let enablesReturnKeyAutomatically = enablesReturnKeyAutomatically {
                uiView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
            } else {
                uiView.enablesReturnKeyAutomatically = false
            }
        }
        
        data: do {
            if uiView.text != text {
                uiView.text = text
            }
        }
    }
    
    public class Coordinator: NSObject, UISearchBarDelegate {
        var base: CustomSearchBarFromUIX
        
        init(base: CustomSearchBarFromUIX) {
            self.base = base
        }
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(true)
        }
        
        public func searchBar(_ searchBar: UIViewType, textDidChange searchText: String) {
            base.text = searchText
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(false)
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.onCancel()
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(base: self)
    }
}

#elseif os(macOS)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar: NSViewRepresentable {
    public typealias NSViewType = NSSearchField
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSSearchField(string: placeholder ?? "")
        
        nsView.delegate = context.coordinator
        nsView.target = context.coordinator
        nsView.action = #selector(context.coordinator.performAction(_:))
        
        nsView.bezelStyle = .roundedBezel
        nsView.cell?.sendsActionOnEndEditing = false
        nsView.isBordered = false
        nsView.isBezeled = true
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSSearchField, context: Context) {
        context.coordinator.base = self
        
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    final public class Coordinator: NSObject, NSSearchFieldDelegate {
        var base: SearchBar
        
        init(base: SearchBar) {
            self.base = base
        }
        
        public func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else {
                return
            }
            
            base.text = textField.stringValue
        }
        
        public func controlTextDidBeginEditing(_ notification: Notification) {
            base.onEditingChanged(true)
        }
        
        public func controlTextDidEndEditing(_ notification: Notification) {
            base.onEditingChanged(false)
        }
        
        @objc
        fileprivate func performAction(_ sender: NSTextField?) {
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#endif

// MARK: - API -

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension CustomSearchBarFromUIX {
    public func customAppKitOrUIKitClass(_ cls: AppKitOrUIKitSearchBar.Type) -> Self {
        then({ $0.customAppKitOrUIKitClass = cls })
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension CustomSearchBarFromUIX {
    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
    #endif
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    public func font(_ font: UIFont) -> Self {
        then({ $0.appKitOrUIKitFont = font })
    }
    
    public func foregroundColor(_ foregroundColor: AppKitOrUIKitColor) -> Self {
        then({ $0.appKitOrUIKitForegroundColor = foregroundColor })
    }
    
    public func searchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        then({ $0.searchBarStyle = searchBarStyle })
    }
    
    public func iconImage(_ icon: UISearchBar.Icon, _ image: AppKitOrUIKitImage) -> Self {
        then({ $0.iconImageConfiguration[icon] = image })
    }
    
    public func showsCancelButton(_ showsCancelButton: Bool) -> Self {
        then({ $0.showsCancelButton = showsCancelButton })
    }
    
    public func onCancel(perform action: @escaping () -> Void) -> Self {
        then({ $0.onCancel = action })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.returnKeyType = returnKeyType })
    }
    
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        then({ $0.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
    
    public func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        then({ $0.isSecureTextEntry = isSecureTextEntry })
    }
    
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.textContentType = textContentType })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
    #endif
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || targetEnvironment(macCatalyst)
extension UISearchBar {
    /// Retrieves the UITextField contained inside the UISearchBar.
    ///
    /// - Returns: the UITextField inside the UISearchBar
    func _retrieveTextField() -> UITextField? {
        findSubview(ofKind: UITextField.self)
    }
}
#endif

extension UIView {
    func findSubview<T: UIView>(ofKind kind: T.Type) -> T? {
        guard !subviews.isEmpty else {
            return nil
        }
        
        for subview in subviews {
            if subview.isKind(of: kind) {
                return subview as? T
            } else if let result = subview.findSubview(ofKind: kind) {
                return result
            }
        }
        
        return nil
    }
}

#endif

// MARK: - Development Preview -

#if os(iOS) || targetEnvironment(macCatalyst)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomSearchBarFromUIX("Search...", text: .constant(""))
            .searchBarStyle(.minimal)
    }
}
#endif
