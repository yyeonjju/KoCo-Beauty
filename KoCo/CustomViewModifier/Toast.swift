//
//  Toast.swift
//  KoCo
//
//  Created by 하연주 on 12/7/24.
//

import SwiftUI

struct Toast: ViewModifier {
    struct ToastState {
        let message : LocalizedStringKey
        var isShowing : Bool
    }
    enum ToastPosition {
        case top,bottom
    }
    
    static let short: TimeInterval = 2
    static let long: TimeInterval = 3.5
    
    let message: LocalizedStringKey
    let position : ToastPosition
    @Binding var isShowing: Bool
    let config: Config
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }
    
    private var toastView: some View {
        VStack {
            if(position == .bottom){
                Spacer()
            }

            if isShowing {
                Group {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(config.textColor)
                        .font(config.font)
                        .padding(8)
                }
                .background(config.backgroundColor)
                .cornerRadius(8)
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
            
            if(position == .top){
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }
    
    struct Config {
        let textColor: Color = .white
        let font: Font = .system(size: 14)
        let backgroundColor: Color = Assets.Colors.gray2.opacity(0.9)
        let duration: TimeInterval
        let transition: AnyTransition = .opacity
        let animation: Animation = .linear(duration: 0.3)
        
    }
}
