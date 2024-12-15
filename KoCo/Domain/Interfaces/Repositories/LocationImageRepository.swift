//
//  LocationImageRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/14/24.
//

import Foundation
import Combine

protocol LocationImageRepository {
    func searchStoreImage(query : String) -> AnyPublisher<[StoreImageItem], Error>
}
