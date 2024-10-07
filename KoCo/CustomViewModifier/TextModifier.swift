//
//  TextModifier.swift
//  KoCo
//
//  Created by 하연주 on 10/6/24.
//

import Foundation
import SwiftUI

struct NormalOutlineText : ViewModifier {
    var outlineColor : Color
    var isFilled : Bool
    var backGroundColor : Color
    
    var fontColor : Color
    var isWidthInfinity : Bool
    var height : CGFloat
    var radius : CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height : height)
            .padding(.horizontal,10)
            .font(.system(size: 14, weight : .bold))
            .foregroundColor(isFilled ? .white : fontColor)
            .frame(maxWidth : isWidthInfinity ? .infinity : nil)
            .background(isFilled ? outlineColor : backGroundColor)
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius:radius)
                    .stroke(outlineColor)
            )
    }
}

struct TitleText : ViewModifier {
    var alignment : Alignment
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .heavy))
            .foregroundColor(Assets.Colors.black)
            .frame(maxWidth : .infinity, alignment: alignment)
    }
}

struct SectionTitleText : ViewModifier {
    var alignment : Alignment
    
    func body(content: Content) -> some View {
        content
            .padding()
            .font(.system(size: 18, weight: .heavy))
            .foregroundColor(Assets.Colors.black)
            .frame(maxWidth : .infinity, alignment: alignment)
    }
}
