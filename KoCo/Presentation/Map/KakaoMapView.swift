//
//  KakaoMapView.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import SwiftUI
import KakaoMapsSDK

//KakaoMapsSDK에서 제공하는 지도를 표시하는 KMViewContainer는 UIKit의 UIView를 상속하기 때문에
//-> SwiftUI에서 KakaoMapsSDK의 view를 표시하기 위해서는 이를 UIViewRepresentable로 Wrapping해야 사용할 수 있다.


//SwiftUI View의 라이프 사이클에 따라서 KMViewContainer를 컨트롤 하기 위해
//KMControllerDelegate를 Coordinator로 구현할 수 있습니다.

struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var isBottomSheetOpen : Bool
    @Binding var showReloadStoreDataButton : Bool
    
    @Binding var isCameraMoving : Bool
    @Binding var cameraMoveTo : LocationLonLat?


    func makeUIView(context: Self.Context) -> KMViewContainer {
        print("🧡makeUIView")
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)

        return view
    }
    

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        print("🧡updateUIView")
        print("🧡updateUIView - isCameraMoving🧡", isCameraMoving)
        print("🧡updateUIView - cameraMoveTo🧡", cameraMoveTo?.longitude, cameraMoveTo?.latitude)
        
        if isCameraMoving, let cameraMoveTo {
            let mapPoint = MapPoint(longitude: cameraMoveTo.longitude, latitude: cameraMoveTo.latitude)
            context.coordinator.moveCameraToCurrentLocation(mapPoint)
        }
       
        if draw {
            DispatchQueue.main.async {
                if context.coordinator.controller?.isEnginePrepared == false {
                    context.coordinator.controller?.prepareEngine()
                }
                
                if context.coordinator.controller?.isEngineActive == false {
                    context.coordinator.controller?.activateEngine()
                }
            }
        }
        else {
            context.coordinator.controller?.pauseEngine()
            context.coordinator.controller?.resetEngine()
        }
    }
    
    func makeCoordinator() -> KakaoMapCoordinator {
        print("🧡makeCoordinator")
        return KakaoMapCoordinator(self)
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        print("🧡dismantleUIView")
        
    }
    
    
    
    
    
}
