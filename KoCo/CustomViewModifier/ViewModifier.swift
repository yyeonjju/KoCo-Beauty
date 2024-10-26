//
//  ViewModifier.swift
//  KoCo
//
//  Created by 하연주 on 10/7/24.
//

import Foundation
import SwiftUI

struct SectionView : ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background(Assets.Colors.white)
            .frame(maxWidth : .infinity)
            .cornerRadius(20)
        
    }
}

struct OutlineView : ViewModifier {
    var outlineColor : Color
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius:10)
                    .stroke(outlineColor)
            )
    }
}
