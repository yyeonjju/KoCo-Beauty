//
//  DefaultMyStoreRepository.swift
//  KoCo
//
//  Created by 하연주 on 12/17/24.
//

import Foundation

final class DefaultMyStoreRepository : MyStoreRepository {
    var myStoreRealmManger : any RealmManagerType & MyStoreRealmMangerType
    
    init(myStoreRealmManger : any RealmManagerType & MyStoreRealmMangerType) {
        self.myStoreRealmManger = myStoreRealmManger
    }
    
    
    
    func getMyStoreInfo(id : String) -> MyStoreInfo? {
        return myStoreRealmManger.myStore(for: id)
    }
    
    func switchFlagStatus(storeID : String, to : Bool, storeData : LocationDocument) {
        myStoreRealmManger.toggleFlag(storeID: storeID, to: to, storeData: storeData)
    }
    
    func addReview(storeID : String, reviewContent : ReviewContent, storeInfo : LocationDocument) {
        myStoreRealmManger.addReview(storeID: storeInfo.id, reviewContent: reviewContent, storeInfo: storeInfo)
    }
    
}
