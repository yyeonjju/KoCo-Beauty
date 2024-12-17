//
//  Router.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import Alamofire


enum Router{
    case searchStore(baseURL : String, query : String, longitude : String, latitude : String, size : Int)
    case searchStoreImage(baseURL : String, query : String)
}

extension Router : TargetType {
    var baseURL: String {
        switch self {
        case .searchStore(let baseURL, _, _, _, _) :
            return baseURL
        case .searchStoreImage(let baseURL, _) :
            return baseURL
        }
    }
    
    var path: String {
        switch self {
        case .searchStore:
            return APIURL.searchStore
        case .searchStoreImage:
            return APIURL.searchStoreImage
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .searchStore, .searchStoreImage :
            return .get
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchStore( _ ,let query, let longitude, let latitude, let size) :
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "x", value: longitude),
                URLQueryItem(name: "y", value: latitude),
                URLQueryItem(name: "size", value: String(size)),
//                URLQueryItem(name: "sort", value: "accuracy"), //distance or accuracy
//                URLQueryItem(name: "radius", value: "20000")
            ]
        case .searchStoreImage(_, let query) :
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "display", value: "3")
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
        case .searchStoreImage :
            return [
                "X-Naver-Client-Id": APIKey.naverClientID,
                "X-Naver-Client-Secret" : APIKey.naverClientSecret
            ]
        }
    }
    
}
