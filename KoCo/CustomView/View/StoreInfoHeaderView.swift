//
//  StoreInfoHeaderView.swift
//  KoCo
//
//  Created by 하연주 on 11/17/24.
//

import SwiftUI

struct StoreInfoHeaderView : View {
    var placeName : String
    var categoryText : String
    var distance : String? = nil
    var addressName : String
    
    init(placeName: String, categoryText: String, distance: String? = nil, addressName: String) {
        self.placeName = placeName
        self.categoryText = categoryText
        self.distance = distance
        self.addressName = addressName
    }
    
    var body: some View {
        VStack{
            HStack {
                //매장이름
                Text(placeName)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.skyblue)
                    .lineLimit(1)

                //카테고리 이름
                Text(categoryText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding(.bottom,4)
            
            HStack{
                if let distance {
                    Text(distance + "m")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Text(addressName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding(.bottom,4)
        }

    }
}
