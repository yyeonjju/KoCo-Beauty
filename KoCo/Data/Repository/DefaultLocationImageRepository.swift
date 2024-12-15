//
//  DefaultLocationImageRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/15/24.
//

import Foundation
import Combine

final class DefaultLocationImageRepository : LocationImageRepository {
    private var cancellables = Set<AnyCancellable>()
    
    func searchStoreImage(query : String) -> AnyPublisher<[StoreImageItem], Error> {
        return NetworkManager.shared.searchStoreImage(query: query)
            .map{$0.toDomain().items}
            .eraseToAnyPublisher()
    }

}
