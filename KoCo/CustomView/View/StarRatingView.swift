//
//  StarRatingView.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var max: Int = 5
    var operation : Operation = .create
    
    private func starColor(index: Int) -> Color {
        return index <= rating ? Assets.Colors.pointYellow : Assets.Colors.gray4
    }
    
    var body: some View {
           HStack {
               ForEach(1..<(max + 1), id: \.self) { index in
                   Assets.SystemImage.starFill
                       .font(.system(size: 27))
                       .foregroundColor(self.starColor(index: index))
                       .onTapGesture {
                           if(operation != .read){
                               self.rating = index
                           }
                       }
                       
               }
           }
       }
}

