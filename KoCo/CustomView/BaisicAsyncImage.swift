//
//  BaisicAsyncImage.swift
//  KoCo
//
//  Created by 하연주 on 10/7/24.
//

import SwiftUI

struct BaisicAsyncImage: View {
    var url : String?
    var width : CGFloat = 80
    var height : CGFloat = 80
    var radius : CGFloat = 4
    
    var allowEnlarger : Bool = false
    var allowMagnificationGesture : Bool = false
    
    
    var body: some View {
        VStack {
            if let url {
                AsyncImage(url: URL(string: url)){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .asEnlargeImage(
                                image :image,
                                allowEnlarger : allowEnlarger,
                                allowMagnificationGesture: allowMagnificationGesture
                            )

                        
                    } else if phase.error != nil {
                        defaultContent // Indicates an error.
                    } else {
                        ProgressView() // Acts as a placeholder.
                    }
                }
            } else {
                defaultContent
            }
        }
        .frame(width : width, height : height)
        .background(Color.gray5)
        .cornerRadius(radius)
        .scaledToFit()
    }
    
    private var defaultContent : some View {
        Color.gray5
            .overlay {
                Assets.SystemImage.photo
                    .foregroundStyle(.gray3)
            }
    }
    

}
