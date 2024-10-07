//
//  ShowDetailToggleButton.swift
//  KoCo
//
//  Created by 하연주 on 10/7/24.
//

import SwiftUI

struct ShowDetailToggleButton: View {
    @Binding var detailShown : Bool
    
    var body: some View {
        Button {
            withAnimation {
                detailShown.toggle()
            }

        }label : {
            Assets.SystemImage.chevronDown
                .foregroundStyle(Assets.Colors.black)
                .rotationEffect(.degrees(detailShown ? -180 : 0))
                .padding()
        }
    }
}

//#Preview {
//    ShowDetailToggleButton()
//}

/* 이런식으로 사용
 VStack{
     HStack {
         Text("태그")
             .asSectionTitleText()
         
         ShowDetailToggleButton(detailShown: $isOpen)
     }
     
     
     VStack{
         
         
     }
     .frame(height : isOpen ? 300 : 0)
     
 }
 .asSectionView()
 .padding(.bottom,5)
 
 */
