//
//  StarRatingView.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var max: Int = 5
    var operation : Operation = .create
    
    // 현재 드래그하고 있는 위치를 감지하고 DragGesture 구조체의 .updating 함수로 현재 드래그 하고 있는 위치에 대해 업데이트해준다
    @GestureState private var location: CGPoint = .zero
    
    var body: some View {
        HStack {
            ForEach(1..<(max + 1), id: \.self) { number in
                Assets.SystemImage.starFill
                    .font(.system(size: 27))
                    .foregroundColor(starColor(index: number))
                    .background(rectReader(index: number))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .updating($location) { (value, state, transaction) in
                                state = value.location
                            }
                    )
                
            }
        }
    }
    
    private func starColor(index: Int) -> Color {
        return index <= rating ? Assets.Colors.pointYellow : Assets.Colors.gray4
    }
    
   
    private func rectReader(index: Int) -> some View {
        return GeometryReader { (geometry) -> AnyView in
            if geometry.frame(in: .global).contains(self.location) {
 //✅ 지금 내가 드레그 하고 있는위치(self.location)가 index번째의 셀영역에 (셀의 배경 영역) 포함되어 있으면 rating을 index 값으로 업데이트
                DispatchQueue.main.async {
                    if(self.rating != index) {
                        self.rating = index
                    }
                }
            }
            
            return AnyView(Rectangle().fill(Color.clear))
        }
    }
  
}


