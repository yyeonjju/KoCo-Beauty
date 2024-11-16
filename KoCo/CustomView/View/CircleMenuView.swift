//
//  CircleMenuView.swift
//  KoCo
//
//  Created by 하연주 on 11/16/24.
//

import SwiftUI

struct CircleMenuView: View {
    var backgroundSize : CGSize = CGSize(width: 36, height: 36)
    var iconSize : CGSize = CGSize(width: 18, height: 18)
    var icon : Image
    
    var body: some View {
        Circle()
            .fill(Assets.Colors.white)
            .frame(width: backgroundSize.width, height:  backgroundSize.height)
            .shadow(color: Assets.Colors.black.opacity(0.4), radius: 3)
            .overlay {
                icon
                    .resizable()
                    .foregroundStyle(Assets.Colors.gray2)
                    .scaledToFit()
                    .frame(width: iconSize.width, height:  iconSize.height)
            }
        
    }
}
