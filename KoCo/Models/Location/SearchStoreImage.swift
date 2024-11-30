//
//  SearchStoreImage.swift
//  KoCo
//
//  Created by 하연주 on 11/30/24.
//

import Foundation

struct SearchStoreImageResponse : Decodable {
//    let lastBuildDate : Date
    let total : Int
    let start : Int
    let display : Int
    let items : [StoreImageItem]
}

struct StoreImageItem : Decodable, Hashable {
    let title : String
    let link : String
    let thumbnail : String
    let sizeheight : String
    let sizewidth : String
}
