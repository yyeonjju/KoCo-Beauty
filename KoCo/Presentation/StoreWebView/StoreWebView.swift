//
//  StoreWebView.swift
//  KoCo
//
//  Created by 하연주 on 10/6/24.
//

import SwiftUI

struct StoreWebView: View {
    var placeUrl : String
    
    var body: some View {
        WebView(url: placeUrl)
            .ignoresSafeArea(edges: .bottom)
    }
}

//#Preview {
//    StoreWebView()
//}
