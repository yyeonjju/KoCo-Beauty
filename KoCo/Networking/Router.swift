//
//  Router.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import Alamofire


enum Router{
    case searchStore(query : String, longitude : String, latitude : String)
}

extension Router : TargetType {
    var baseURL: String {
        return APIURL.baseURL + APIURL.version
    }
    
    var path: String {
        switch self {
        case .searchStore:
            return APIURL.searchStore
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .searchStore :
            return .get
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchStore(let query, let longitude, let latitude) :
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "x", value: longitude),
                URLQueryItem(name: "y", value: latitude),
//                URLQueryItem(name: "sort", value: "accuracy"), //distance or accuracy
//                URLQueryItem(name: "radius", value: "20000")
            ]

        }
    }
    
    var body: Data? {
        return nil
    }
    
    var header: [String : String] {
        
        switch self {
        case .searchStore :
            return [
                "Authorization": "KakaoAK \(APIKey.kakaoRestAPIKey)"
            ]

        }
    }
    
}
