//
//  DefaultLocationDataRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/15/24.
//

import Foundation
import Combine

final class DefaultLocationDataRepository : LocationDataRepository {
    private var cancellables = Set<AnyCancellable>()
    
    var networkManager : NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func searchStoreData(query : String, location : LocationCoordinate, size : Int) -> AnyPublisher<[LocationDocument], Error> {
        return networkManager.searchStoreData(query: query, location: location, size: size)
            .map{$0.toDomain().documents}
            .eraseToAnyPublisher()
    }

}
