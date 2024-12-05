//
//  NetworkManager.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import Combine


enum FetchError : Error {
//    case fetchEmitError // 만에 하나 리턴한 single에서 에러를 방출했을떄 발생하는 에러
    
    case urlComponent
//    case url
//    case urlRequestError
//    case failedRequest
//    case noData
//    case invalidResponse
//    case failResponse(code : Int, message : String)
//    case invalidData
//    case noUser
    
    var errorMessage : String {
        switch self {
//        case .fetchEmitError :
//            return "알 수 없는 에러입니다."
            
        case .urlComponent :
            return "urlComponent을 생성하지 못했습니다. "
//        case .url :
//            return "잘못된 url입니다"
//        case .urlRequestError:
//            return "urlRequest 에러"
//        case .failedRequest:
//            return "요청에 실패했습니다."
//        case .noData:
//            return "데이터가 없습니다."
//        case .invalidResponse:
//            return "유효하지 않은 응답입니다."
//        case .failResponse(let errorCode, let message):
//            return "\(errorCode)error : \(message)"
//        case .invalidData:
//            return "데이터 파싱 에러"
//        case .noUser :
//            return "유저가 명확하지 않습니다."
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private func fetch<T : Decodable> (model : T.Type, fetchRouter : Router) -> AnyPublisher<T, Error> {
        
        guard let request = try? fetchRouter.asURLRequest() else {
            return Fail(error: "Couldn't create request" as! Error).eraseToAnyPublisher()
        }
        print("request💚", request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
//            .print("💚")
//            .map{
//                if $0.response
//            }
            .map{$0.data}
            .decode(type: model.self, decoder: JSONDecoder())
//            .print("💚💚")
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

extension NetworkManager {
    func searchStoreData (query : String, location : LocationCoordinate, size : Int) -> AnyPublisher<SearchLocationReapose, Error> {
        let router = Router.searchStore(baseURL : APIURL.kakaoBaseURL,query: query, longitude : String(location.longitude), latitude : String(location.latitude), size : size)
        return fetch(model: SearchLocationReapose.self, fetchRouter: router)
    }
    
    func searchStoreImage (query : String) -> AnyPublisher<SearchStoreImageResponse, Error> {
        let router = Router.searchStoreImage(baseURL : APIURL.naverBaseURL,query: query)
        return fetch(model: SearchStoreImageResponse.self, fetchRouter: router)
    }
    
}
