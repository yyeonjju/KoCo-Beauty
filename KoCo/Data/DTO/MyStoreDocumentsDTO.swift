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
    
    func convertToLocationDocument () -> LocationDocument {
        LocationDocument(
            id: self.KakaoPlaceID,
            placeName: self.KakaoPaceName,
            distance: "-",
            placeUrl: self.KakaoPlaceUrl,
            categoryName: self.categoryName,
            addressName: self.addressName,
            roadAddressName: self.roadAddressName,
            phone: self.phone,
            x: String(self.longitude_x),
            y: String(self.latitude_y)
        )
    }
    
    
}

class ReviewContent: EmbeddedObject {
    @Persisted var photoFileNames: List<String>
    @Persisted var storeReviewText : String
    @Persisted var productReviewText : String
    @Persisted var reviewTags : List<ReviewTagItem> //new
    @Persisted var starRate : Int
    
    convenience init(photoFileNames : List<String>, storeReviewText: String, productReviewText: String, reviewTags : List<ReviewTagItem>, starRate: Int) {
        self.init()
        self.photoFileNames = photoFileNames
        self.storeReviewText = storeReviewText
        self.productReviewText = productReviewText
        self.reviewTags = reviewTags
        self.starRate = starRate
    }
    
}


//new
enum ReviewTagItem: Int, PersistableEnum {
    case reasonablePrice = 0
    case worthThePrice = 1
    
    case storeIsClean = 2
    case storeIsNotClean = 3
    
    case storeIsTrendy = 4
    
    case goodProductQuality = 5
    
    case staffIsAttentive = 6
    case staffIsNotAttentive = 7
    
    case convenientForParking = 8
    case waitingSpaceIsComfortable = 9
    case convenientToMakeReservation = 10
    case recommend = 11
    case notRecommend = 12

}


//    [
//
//        "가격이 합리적임",
//        "비싼 만큼 가치 있음",
//
//        "매장이 청결함",
//        "매장이 청결하지 않음",
//
//        "매장이 트렌디함",
//
//        "제품 퀄리티 좋음",
//
//        "직원이 친절함",
//        "직원이 불친절함",
//
//        "주차가 편리함",
//        "대기 공간이 편안함",
//        "예약이 편리함",
//        "추천",
//        "비추천"
//    ]

//    [
//        "가격이 합리적임", "비싼 만큼 가치 있음", "매장이 청결함", "매장이 트렌디함", "제품 퀄리티 좋음", "직원이 친절함", "주차가 편리함", "대기 공간이 편안함", "예약이 편리함", "추천", "비추천"
//    ]

//    [
//        "합리적인 가격", "비싼 만큼 가치 있음", "청결", "제품 퀄리티 좋음", "친절", "트렌디함", "주차 편리", "편안한 대기 공간", "추천", "비추천", "편리한 예약"
//    ]
