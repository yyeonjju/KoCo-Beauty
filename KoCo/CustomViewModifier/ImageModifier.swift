//
//  ImageModifier.swift
//  KoCo
//
//  Created by 하연주 on 12/6/24.
//

import Foundation
import SwiftUI

struct EnlargeImage : ViewModifier {
    var image : Image //content 는 특정 뷰로 캐스팅하지 못해서 이미지를 파라미터로 받아줌
    var allowEnlarger : Bool
    var allowMagnificationGesture : Bool
    
    @GestureState private var scale: CGFloat = 1.0
    @State private var imageEnlargerSheetOpened : Bool = false
    
    func body(content: Content) -> some View {
        
        content
            .onTapGesture {
                if allowEnlarger {
                    imageEnlargerSheetOpened = true
                }
            }
            .sheet(isPresented: $imageEnlargerSheetOpened) {
                image
                    .resizable()
                    .frame(maxWidth : .infinity, maxHeight: .infinity)
                    .scaledToFit()
                    .scaleEffect(scale) //.scaleEffect() 함수 -> 뷰의 Scale을 변경
                    .gesture(
                        allowMagnificationGesture
                        ? magnificationGesture
                        : nil
                    )
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($scale) {value, gestureState, transaction in
                
                gestureState = value
            }
    }
}
