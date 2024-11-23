//
//  ReviewSectionView.swift
//  KoCo
//
//  Created by 하연주 on 10/25/24.
//

import Foundation
import SwiftUI

struct ReviewSectionView<Content : View>: View {
    @Binding var isContentShown : Bool
    var title : LocalizedStringKey
    var content : () -> Content
    
    init(
        isContentShown : Binding<Bool>,
        title : LocalizedStringKey,
        @ViewBuilder content : @escaping () -> Content
    ) {
        self._isContentShown = isContentShown
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack{
            HStack{
                Text(title)
                    .asSectionTitleText()
                
                Spacer()
                
                Button{
                    withAnimation{
                        isContentShown.toggle()
                    }
                }label: {
                    Image(systemName: isContentShown ? "chevron.down" : "chevron.right")
                        .imageScale(.small)
                        .tint(Assets.Colors.gray3)
                }
                .padding()
                
            }

            if isContentShown {
                content()
            }

               
        }
        .asSectionView()
    }
}
