//
//  NameSpace.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import UIKit
import SwiftUI

enum MyStoreMode {
    case entire
    
    case flaged
    case reviewExist
}

enum RepositoryError : Error {
    case noStore
    case noReviewContent
}

enum Operation {
    case create
    case edit
    
    case read
}

enum Assets {
    enum Colors {
        static let skyblue = Color("skyblue")
        static let pointYellow = Color("pointYellow")
        
        static let black = Color("black")
        static let gray1 = Color("gray1")
        static let gray2 = Color("gray2")
        static let gray3 = Color("gray3")
        static let gray4 = Color("gray4")
        static let gray5 = Color("gray5")
        static let white = Color("white")
    }
    
    enum SystemImage {
        static let arrowClockwise = Image(systemName: "arrow.clockwise")
        static let phoneFill = Image(systemName: "phone.fill")
        static let flag = Image(systemName: "flag")
        static let flagFill = Image(systemName: "flag.fill")
        static let xmark = Image(systemName: "xmark")
        static let chevronDown = Image(systemName: "chevron.down")
        static let plusCircleFill = Image(systemName: "plus.circle.fill")
        static let starFill = Image(systemName: "star.fill")
        
        static let ellipsis = Image(systemName: "ellipsis")
        static let menucard = Image(systemName: "menucard")
        
        
//        static let pencilLine = Image(systemName: "pencil.line")
//        static let highlighter = Image(systemName: "highlighter")
//        static let bookClosed = Image(systemName: "book.closed")
//        static let noteText = Image(systemName: "note.text")
        
    }
}

enum MapInfo {
    static let viewName = "mapview"
    static let viewInfoName = "map"
    
    enum Poi {
        //화장품 매장에 표시에 대한 layer
        static let storeLayerID = "storeLayer"
        static let basicPoiPinStyleID = "basicPoiPinStyle"
        static let tappedPoiPinStyleID = "tappedPoiPinStyle"
        
        //현재 위치 표시에 대한 layer
        static let currentPointlayerID = "currentPointlayer"
        static let currentPointPoiPinStyleID = "currentPointPoiPinStyle"
        
        //선택된 myStore 매장 표시에 대한 layer
        static let myStoreLayerID = "myStoreLayer"
        static let myStorePoiPinStyleID = "myStorePoiPinStyle"
        static let tappedMyStorePoiPinStyleID = "tappedMyStorePoiPinStyle"
    }

}

enum ReviewSection {
    static let addPhotos : LocalizedStringKey = "영수증/사진 기록"
    static let addStoreReview : LocalizedStringKey = "매장 방문 후기"
    static let addProductReview : LocalizedStringKey = "화장품/제품 사용 후기"
    static let addTags : LocalizedStringKey = "태그"
    static let addStarRate : LocalizedStringKey = "별점"
}

enum ReviewTagLoalizedStringKey {
    static let reasonablePrice : LocalizedStringKey = "reviewTag_reasonablePrice"
    static let worthThePrice : LocalizedStringKey = "reviewTag_worthThePrice"
    static let storeIsClean : LocalizedStringKey = "reviewTag_storeIsClean"
    static let storeIsNotClean : LocalizedStringKey =  "reviewTag_storeIsNotClean"
    static let storeIsTrendy : LocalizedStringKey = "reviewTag_storeIsTrendy"
    static let goodProductQuality : LocalizedStringKey = "reviewTag_goodProductQuality"
    static let staffIsAttentive : LocalizedStringKey = "reviewTag_staffIsAttentive"
    static let staffIsNotAttentive : LocalizedStringKey = "reviewTag_staffIsNotAttentive"
    static let convenientForParking  :LocalizedStringKey = "reviewTag_convenientForParking"
    static let waitingSpaceIsComfortable : LocalizedStringKey = "reviewTag_waitingSpaceIsComfortable"
    static let convenientToMakeReservation : LocalizedStringKey = "reviewTag_convenientToMakeReservation"
    static let recommend : LocalizedStringKey = "reviewTag_recommend"
    static let notRecommend : LocalizedStringKey = "reviewTag_notRecommend"
    
    static let tagList = [
        ReviewTagLoalizedStringKey.reasonablePrice ,
        ReviewTagLoalizedStringKey.worthThePrice ,
        ReviewTagLoalizedStringKey.storeIsClean ,
        ReviewTagLoalizedStringKey.storeIsNotClean ,
        ReviewTagLoalizedStringKey.storeIsTrendy ,
        ReviewTagLoalizedStringKey.goodProductQuality ,
        ReviewTagLoalizedStringKey.staffIsAttentive ,
        ReviewTagLoalizedStringKey.staffIsNotAttentive ,
        ReviewTagLoalizedStringKey.convenientForParking ,
        ReviewTagLoalizedStringKey.waitingSpaceIsComfortable ,
        ReviewTagLoalizedStringKey.convenientToMakeReservation ,
        ReviewTagLoalizedStringKey.recommend ,
        ReviewTagLoalizedStringKey.notRecommend ,
    ]
}


enum ScreenSize {
    static var width : CGFloat {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return UIScreen.main.bounds.width}
        return window.screen.bounds.width
    }
    
    static var height : CGFloat {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return UIScreen.main.bounds.height}
        return window.screen.bounds.height
    }
    
}
