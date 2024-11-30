//
//  BaisicAsyncImage.swift
//  KoCo
//
//  Created by 하연주 on 10/7/24.
//

import SwiftUI

struct BaisicAsyncImage: View {
    var url : String
    var width : CGFloat = 80
    var height : CGFloat = 80
    var radius : CGFloat = 4
    
    var body: some View {
        AsyncImage(url: URL(string: url)){ image in
            image
                .resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width : width, height : height)
        .background(Color.gray5)
        .cornerRadius(radius)
        .scaledToFit()
    }
}
