//
//  View++.swift
//  KoCo
//
//  Created by 하연주 on 10/6/24.
//

import Foundation
import SwiftUI


//TextModifier
extension View{
    func asNormalOutlineText(outlineColor : Color = .skyblue, isFilled : Bool = false, backGroundColor : Color = .clear, fontColor : Color = .skyblue, isWidthInfinity : Bool = false, height : CGFloat = 32, radius : CGFloat = 12 ) -> some View {
        modifier(NormalOutlineText(outlineColor : outlineColor, isFilled : isFilled, backGroundColor : backGroundColor, fontColor : fontColor, isWidthInfinity : isWidthInfinity, height : height, radius : radius ))
    }
    
    func asTitleText (alignment : Alignment = .leading) -> some View {
        modifier(TitleText(alignment : alignment))
    }
    
    func asSectionTitleText (alignment : Alignment = .leading) -> some View {
        modifier(SectionTitleText(alignment : alignment))
    }
}

//ViewModifier
extension View {
    func asSectionView(alignment : Alignment = .leading) -> some View {
        modifier(SectionView())
    }
    
    func asOutlineView(outlineColor : Color = Assets.Colors.skyblue) -> some View {
        modifier(OutlineView(outlineColor: outlineColor))
    }
}

//ImageModifier
extension View {
    //이미지 확대를 위한 수정자
    func asEnlargeImage(image :Image ,allowEnlarger : Bool = false,allowMagnificationGesture : Bool = false) -> some View{
        modifier(EnlargeImage(
            image :image,
            allowEnlarger : allowEnlarger,
            allowMagnificationGesture: allowMagnificationGesture
        ))
    }
}

//Toast
extension View {
    func toast(message: LocalizedStringKey,
               position : Toast.ToastPosition = .bottom,
               isShowing: Binding<Bool>,
               config: Toast.Config) -> some View {
        self.modifier(Toast(message: message,
                            position : position,
                            isShowing: isShowing,
                            config: config))
    }
    
    func toast(message: LocalizedStringKey,
               position : Toast.ToastPosition = .bottom,
               isShowing: Binding<Bool>,
               duration: TimeInterval) -> some View {
        self.modifier(Toast(message: message,
                            position : position,
                            isShowing: isShowing,
                            config: .init(duration: duration)))
    }
}
