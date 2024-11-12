//
//  ReviewTag.swift
//  KoCo
//
//  Created by 하연주 on 11/12/24.
//

import Foundation

//realm 에 id int 값을 바탕으로  List<Int>로 저장해주려고 하면
//값을 받았을 때 어덯게 다시 string으로 해줄건데..

//저장할 떄 string -> int
//받아왔을 때 int -> string
//
//enum ReviewTag: String, CaseIterable {
//    
//    case reasonablePrice = "가격이 합리적임"
//    case worthThePrice = "비싼 만큼 가치 있음"
//    
//    case storeIsClean = "매장이 청결함"
//    case storeIsNotClean =  "매장이 청결하지 않음"
//    
//    case storeIsTrendy = "매장이 트렌디함"
//    
//    case goodProductQuality = "제품 퀄리티 좋음"
//    
//    case staffIsAttentive = "직원이 친절함"
//    case staffIsNotAttentive = "직원이 불친절함"
//    
//    case convenientForParking = "주차가 편리함"
//    case waitingSpaceIsComfortable = "대기 공간이 편안함"
//    case convenientToMakeReservation = "예약이 편리함"
//    case recommend = "추천"
//    case notRecommend = "비추천"
//    
//
//    //🚨 각 case별 toID 값 절대 바뀌면 안됨 - ID int 값으로 realm에 저장되기 때문🚨
//    var toID : Int {
//        switch self {
//        case .reasonablePrice:
//            1
//        case .worthThePrice:
//            2
//        case .storeIsClean:
//            3
//        case .storeIsNotClean:
//            4
//        case .storeIsTrendy:
//            5
//        case .goodProductQuality:
//            6
//        case .staffIsAttentive:
//            7
//        case .staffIsNotAttentive:
//            8
//        case .convenientForParking:
//            9
//        case .waitingSpaceIsComfortable:
//            10
//        case .convenientToMakeReservation:
//            11
//        case .recommend:
//            12
//        case .notRecommend:
//            13
//        }
//    }
//}
