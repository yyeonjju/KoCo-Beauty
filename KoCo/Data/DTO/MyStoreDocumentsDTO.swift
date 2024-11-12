//
//  MyStoreDocumentsDTO.swift
//  KoCo
//
//  Created by 하연주 on 10/27/24.
//

import Foundation
import RealmSwift

//모델
//플래그된 스토어, 리뷰 적은 스토어 따로 저장해야하나?
// => 두개 따로 관리하면 겹치는 데이터를 저장해야할수도 있으므로 비효율적
// => 플래그되거나 리뷰적게되면


final class MyStoreInfo : Object {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var savedAt: Date
    
    @Persisted var KakaoPaceName: String
    @Persisted var KakaoPlaceID: String
    @Persisted var KakaoPlaceUrl: String
    
    @Persisted var latitude_y: Double
    @Persisted var longitude_x: Double
    @Persisted var addressName: String
    @Persisted var roadAddressName: String
    @Persisted var phone: String
    @Persisted var categoryName: String
    
    @Persisted var isFlaged : Bool
    @Persisted var isReviewed : Bool
    @Persisted var reviewContent : ReviewContent?
    
    
    convenience init(savedAt: Date, KakaoPaceName: String, KakaoPlaceID: String, KakaoPlaceUrl: String, latitude_y: Double, longitude_x: Double, addressName: String, roadAddressName: String, phone: String, categoryName: String, isFlaged: Bool, isReviewed: Bool, reviewContent: ReviewContent?) {
        self.init()
        self.savedAt = savedAt
        self.KakaoPaceName = KakaoPaceName
        self.KakaoPlaceID = KakaoPlaceID
        self.KakaoPlaceUrl = KakaoPlaceUrl
        self.latitude_y = latitude_y
        self.longitude_x = longitude_x
        self.addressName = addressName
        self.roadAddressName = roadAddressName
        self.phone = phone
        self.categoryName = categoryName
        self.isFlaged = isFlaged
        self.isReviewed = isReviewed
        self.reviewContent = reviewContent
    }

    
}


class ReviewContent: EmbeddedObject {
//    @Persisted var photo: List<Data>
    @Persisted var storeReviewText : String
    @Persisted var productReviewText : String
    @Persisted var tags : List<ReviewTag>
    @Persisted var starRate : Int
    
    convenience init(storeReviewText: String, productReviewText: String, tags : List<ReviewTag>, starRate: Int) {
        self.init()
        self.storeReviewText = storeReviewText
        self.productReviewText = productReviewText
        self.tags = tags
        self.starRate = starRate
    }
    
}


//PersistableEnum 자체가 CaseIterable 채택하고 있음
enum ReviewTag: String, PersistableEnum {
    
    case reasonablePrice = "가격이 합리적임"
    case worthThePrice = "비싼 만큼 가치 있음"
    
    case storeIsClean = "매장이 청결함"
    case storeIsNotClean =  "매장이 청결하지 않음"
    
    case storeIsTrendy = "매장이 트렌디함"
    
    case goodProductQuality = "제품 퀄리티 좋음"
    
    case staffIsAttentive = "직원이 친절함"
    case staffIsNotAttentive = "직원이 불친절함"
    
    case convenientForParking = "주차가 편리함"
    case waitingSpaceIsComfortable = "대기 공간이 편안함"
    case convenientToMakeReservation = "예약이 편리함"
    case recommend = "추천"
    case notRecommend = "비추천"

}
