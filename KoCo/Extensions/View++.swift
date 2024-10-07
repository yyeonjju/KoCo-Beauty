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
    func asSectionView (alignment : Alignment = .leading) -> some View {
        modifier(SectionView())
    }
}
