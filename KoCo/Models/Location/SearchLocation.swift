//
//  SearchLocation.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation

struct SearchLocationReapose : Decodable {
//    let meta :
    let documents : [LocationDocument]
    
}

struct LocationDocument : Decodable, Equatable {
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


/*
 {
   "meta": {
     "same_name": {
       "region": [],
       "keyword": "카카오프렌즈",
       "selected_region": ""
     },
     "pageable_count": 14,
     "total_count": 14,
     "is_end": true
   },
   "documents": [
     {
       "place_name": "카카오프렌즈 코엑스점",
       "distance": "418",
       "place_url": "http://place.map.kakao.com/26338954",
       "category_name": "가정,생활 > 문구,사무용품 > 디자인문구 > 카카오프렌즈",
       "address_name": "서울 강남구 삼성동 159",
       "road_address_name": "서울 강남구 영동대로 513",
       "id": "26338954",
       "phone": "02-6002-1880",
       "category_group_code": "",
       "category_group_name": "",
       "x": "127.05902969025047",
       "y": "37.51207412593136"
     },
     ...
   ]
 }
 */


