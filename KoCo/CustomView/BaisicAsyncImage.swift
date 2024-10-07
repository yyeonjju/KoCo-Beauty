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
        .cornerRadius(radius)
        .scaledToFit()
//        .padding(2)
    }
}

#Preview {
    BaisicAsyncImage(url : "https://search.pstatic.net/common/?type=b150&src=http://post.phinf.naver.net/MjAyMjA0MTVfMjQ2/MDAxNjUwMDE5NDA4Mjgw.CgQJxztRuJfn4ihLu4eKU7dPasRUnQsy2x5owX4ci-gg.1Snzbi21dWabljj5SyfPUDZI-5NT-U7P32CgewqNSYgg.JPEG/Io7UGYEjtHnI1ViGT2_YIhkgFhWI.jpg")
}
