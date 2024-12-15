//
//  LocationDataRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/14/24.
//

import Foundation
import Combine

protocol LocationDataRepository {
    func searchStoreData(query : String, location : LocationCoordinate, size : Int) -> AnyPublisher<[LocationDocument], Error>
}
