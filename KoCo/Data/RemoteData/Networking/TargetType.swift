//
//  TargetType.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    
    var header: [String: String] { get }
    var parameters: String? { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}


extension TargetType {
    
    func asURLRequest() throws -> URLRequest {
        var request : URLRequest
        
        ///queryItems 를 붙이는 append 메서드가 16이상만 가능
        if #available(iOS 16.0, *) {
            let url = try baseURL.asURL()
            request = try URLRequest(
                url: url.appendingPathComponent(path),
                method: method
            )
            request.url?.append(queryItems: queryItems)
        } else {
            guard var component = URLComponents(string: baseURL) else { throw FetchError.urlComponent}
            
            component.path = path
            component.queryItems = queryItems
            request = URLRequest(url: component.url!)
            request.httpMethod = method.rawValue
        }
        
        request.allHTTPHeaderFields = header
        request.httpBody = body
    
//        print("🌸🌸TargetType - request🌸🌸", request)
//        print("🌸🌸TargetType - request🌸🌸", request.url)
//        print("🌸🌸TargetType - request🌸🌸", request.httpMethod)
        return request
    }
    
}

