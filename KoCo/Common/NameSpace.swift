//
//  NameSpace.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import UIKit

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
