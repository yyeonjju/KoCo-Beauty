//
//  MyStoreRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/17/24.
//

import Foundation

protocol MyStoreRepository {
    func getMyStoreInfo(id : String) -> MyStoreInfo?
    func switchFlagStatus(storeID : String, to : Bool, storeData : LocationDocument)
    func addReview(storeID : String, reviewContent : ReviewContent, storeInfo : LocationDocument)
    
}
