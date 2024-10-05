//
//  NameSpace.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
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
    }

}
