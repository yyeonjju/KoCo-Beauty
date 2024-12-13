//
//  SearchStoreImage.swift
//  KoCo
//
//  Created by 하연주 on 11/30/24.
//

import Foundation

struct SearchStoreImageResponse {
    let items : [StoreImageItem]
}

struct StoreImageItem : Hashable {
    let title : String
    let link : String
//    let thumbnail : String
//    let sizeheight : String
//    let sizewidth : String
}
