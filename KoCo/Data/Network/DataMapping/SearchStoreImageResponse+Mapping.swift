//
//  SearchStoreImageResponse+Mapping.swift
//  KoCo
//
//  Created by 하연주 on 12/13/24.
//

import Foundation

struct SearchStoreImageResponseDTO : Decodable {
//    let lastBuildDate : Date
    let total : Int
    let start : Int
    let display : Int
    let items : [StoreImageItemDTO]
    
    struct StoreImageItemDTO : Decodable {
        let title : String
        let link : String
        let thumbnail : String
        let sizeheight : String
        let sizewidth : String
    }
}




// MARK: - Mappings to Domain


// MARK: - Mappings to Presentation
extension SearchStoreImageResponseDTO {
    func toDomain() -> SearchStoreImageResponse {
        return .init(
            items: items.map{$0.toDomain()}
        )
    }
}

extension SearchStoreImageResponseDTO.StoreImageItemDTO {
    func toDomain() -> StoreImageItem {
        return .init(
            title: title,
            link: link)
    }
}
