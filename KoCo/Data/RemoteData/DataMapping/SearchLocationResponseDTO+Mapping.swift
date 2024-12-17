//
//  SearchLocationResponseDTO+Mapping.swift
//  KoCo
//
//  Created by 하연주 on 12/12/24.
//

import Foundation

struct SearchLocationResponseDTO : Decodable {
//    let meta :
    let documents : [LocationDocumentDTO]
    
}

extension SearchLocationResponseDTO {
    struct LocationDocumentDTO : Decodable, Equatable, Hashable {
        let id : String
        let placeName : String
        let distance : String
        let placeUrl : String
        let categoryName : String
        let addressName : String
        let roadAddressName : String
        let phone : String
        let x : String
        let y : String
        
        
        enum CodingKeys: String, CodingKey {
            case id, distance, phone, x, y
            case placeName = "place_name"
            case placeUrl = "place_url"
            case categoryName = "category_name"
            case addressName = "address_name"
            case roadAddressName = "road_address_name"
        }
    }
}



// MARK: - Mappings to Domain


// MARK: - Mappings to Presentation
extension SearchLocationResponseDTO {
    func toDomain() -> SearchLocationResponse {
        return .init(documents: documents.map{$0.toDomain()})
    }
}

extension SearchLocationResponseDTO.LocationDocumentDTO{
    func toDomain() -> LocationDocument {
        let categories = categoryName.components(separatedBy: ">")
        let categoryText = categories.count>1 ? categories[categories.count-1] : "-"
        
        return .init(id: id,
                     placeName: placeName,
                     distance: distance,
                     placeUrl: placeUrl,
                     categoryName: categoryText,
//                     categoryName:categoryName,
                     addressName: addressName,
                     roadAddressName: roadAddressName,
                     phone: phone,
                     x: x,
                     y: y)
    }
}



