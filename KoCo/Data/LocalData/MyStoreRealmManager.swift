//
//  MyStoreRealmManager.swift
//  KoCo
//
//  Created by 하연주 on 11/11/24.
//

import Foundation

protocol MyStoreRealmMangerType {
    func myStoreList(mode : MyStoreMode) -> [MyStoreInfo]
    func myStore(for storeID : String) -> MyStoreInfo?
    func toggleFlag(storeID : String, to : Bool, storeData : LocationDocument)
    func addReview(storeID : String, reviewContent : ReviewContent, storeInfo : LocationDocument)
}

final class MyStoreRealmManager : BaseRealmManager, MyStoreRealmMangerType {
    
    //realm에 저장된 myStore 리스트
    func myStoreList(mode : MyStoreMode = .entire) -> [MyStoreInfo] {
        switch mode {
        case .entire :
            if let results = getAllObjects(tableModel: MyStoreInfo.self) {
                return Array(results)
            }else {
                return []
            }
            
        case .reviewExist :
            if let results = getAllObjects(tableModel: MyStoreInfo.self)?.where({$0.isReviewed}) {
                return Array(results)
            }else {
                return []
            }
            
        case .flaged :
            if let results = getAllObjects(tableModel: MyStoreInfo.self)?.where({$0.isFlaged}) {
                return Array(results)
            }else {
                return []
            }
            
        }
    }
    
    //realm에 존재하는가 여부 (플래그 또는 리뷰 작성)
    func myStore(for storeID : String) -> MyStoreInfo? {
       return getAllObjects(tableModel: MyStoreInfo.self)?.first(where: {$0.KakaoPlaceID == storeID})
    }
    
    //리뷰 있는 매장 데이터 삭제할 때는 파일매니저에 저장한 이미지까지 함께 삭제
    //TODO: 🌸 파일 매니저에 저장된 사진들 삭제🌸
    func removeItemWithFileManagerImage() {
        
    }
    
    //리뷰 저장
    func addReview(storeID : String, reviewContent : ReviewContent, storeInfo : LocationDocument) {
        // myStoreInfo 테이블에 저장되어 있는가
        if let myStore = myStore(for: storeID){
            //원래 있던 객체 수정
            try! realm.write{
                myStore.isReviewed = true
                myStore.reviewContent = reviewContent
            }
        }else {
            guard let latitude = Double(storeInfo.y), let longitude = Double(storeInfo.x) else{return }
            
            let storeInfo = MyStoreInfo(savedAt: Date(), KakaoPaceName: storeInfo.placeName, KakaoPlaceID: storeInfo.id, KakaoPlaceUrl: storeInfo.placeUrl, latitude_y: latitude, longitude_x: longitude, addressName: storeInfo.addressName, roadAddressName: storeInfo.roadAddressName, phone: storeInfo.phone, categoryName: storeInfo.categoryName, isFlaged: false, isReviewed: true, reviewContent: reviewContent)
            
            createItem(storeInfo)
        }
    }
    
    
    //isFlaged 토글
    func toggleFlag(storeID : String, to : Bool, storeData : LocationDocument) {
        // myStoreInfo 테이블에 저장되어 있는가
        if let myStore = myStore(for: storeID) {
            //저장되어 있는 매장이라면
            switch to {
                
            case true :
                editItem(MyStoreInfo.self, at: myStore.id, editKey: "isFlaged", to: to)
                
            case false :
                if myStore.isReviewed {
                    editItem(MyStoreInfo.self, at: myStore.id, editKey: "isFlaged", to: to)
                } else {
                    //isFlaged를 false로 저장할때는 테이블에서 아얘 삭제해줘야하는 것에 대한 고려가 필요함
                    //isReviewed도 false인 상태에서는 리스트에서 아얘 삭제
                    removeItem(myStore)
                }
                
            }
        } else {
            //저장되어있지 않은 매장이라면
            // to가 true일 수 밖에 없음
            if to {

                guard let latitude = Double(storeData.y), let longitude = Double(storeData.x) else {
                    return
                }

                let storeInfo = MyStoreInfo(savedAt: Date(), KakaoPaceName: storeData.placeName, KakaoPlaceID: storeData.id, KakaoPlaceUrl: storeData.placeUrl, latitude_y: latitude, longitude_x: longitude, addressName: storeData.addressName, roadAddressName: storeData.roadAddressName, phone: storeData.phone, categoryName: storeData.categoryName, isFlaged: to, isReviewed: false, reviewContent: nil)
                
                createItem(storeInfo)
            }

            
            
        }
    }

}
