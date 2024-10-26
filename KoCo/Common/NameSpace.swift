//
//  NameSpace.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import UIKit
import SwiftUI

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
