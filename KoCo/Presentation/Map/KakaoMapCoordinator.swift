//
//  KakaoMapCoordinator.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import KakaoMapsSDK


final class KakaoMapCoordinator: NSObject, MapControllerDelegate {
    var parent: KakaoMapView
    var first: Bool // 처음 위치로 카메라 이동시켜주기 위해
    var auth: Bool //카카오 sdk 인증
    
    var controller: KMController?
    var container: KMViewContainer?
    var tappedPoi : Poi?
    
    init(_ kakaoMapView: KakaoMapView) {
        self.parent = kakaoMapView
        first = true
        auth = false
        super.init()
    }
    
    let testLocations = [
        MapPoint(longitude: 126.9769, latitude: 37.5759),//광화문
        MapPoint(longitude: 126.9882, latitude: 37.5512),//남산타워
        MapPoint(longitude: 126.9771, latitude: 37.5696), //청계천
        MapPoint(longitude: 126.9990, latitude: 37.5704), //광장시장
        MapPoint(longitude: 127.1027, latitude: 37.5130), //롯데타워
        MapPoint(longitude: 127.0982, latitude: 37.5110), //롯데월드
        MapPoint(longitude: 127.0384, latitude: 37.4760), //양재천
        MapPoint(longitude: 126.9326, latitude: 37.5281), //여의도 한강공원
        MapPoint(longitude: 126.9297, latitude: 37.5262), //여의도 더현대
    ]
    
    let firstPosition = MapPoint(longitude: 126.9769, latitude: 37.5759)//광화문
    
    


    
    //KakaoMapView의 makeUIView 시점에
    func createController(_ view: KMViewContainer) {
        print("🧡🧡🧡createController")
        container = view
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }
    
    //addViewSucceeded ( 뷰가 성공적으로 추가 되었을 때 )
    func viewInit(viewName: String) {
        print("🧡🧡🧡viewInit")
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        view.eventDelegate = self
        
        createLabelLayer()
        createPoiStyle()
        createPois()
    }
    
    // MARK: - delegate function

    //📍 1️⃣ Engine을 start 하고 뷰를 드로잉 하기 시작
    func addViews() {
        print("🧡🧡🧡addViews")
        let defaultPosition: MapPoint = firstPosition
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: MapInfo.viewName, viewInfoName: MapInfo.viewInfoName, defaultPosition: defaultPosition)
        
        controller?.addView(mapviewInfo)
    }
    
    //📍 2️⃣ addViews 성공했을 때
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("💚addViewSucceeded")
        let view = controller?.getView(MapInfo.viewName)
        view?.viewRect = container!.bounds
        
        viewInit(viewName: viewName)
    }
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("💚addViewSucceeded")
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
//    func containerDidResized(_ size: CGSize) {
//        print("🧡🧡🧡containerDidResized")
//        //addViews에서 viewName으로 적용해놓았던 "mapview"라는 이름으로 뷰를 가져옴
//        let mapView: KakaoMap? = controller?.getView(MapInfo.viewName) as? KakaoMap
//        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
////        if first {
////            let cameraUpdate: CameraUpdate = CameraUpdate.make(target: firstPosition, mapView: mapView!)
////            mapView?.moveCamera(cameraUpdate)
////            first = false
////        }
//    }
    
    func authenticationSucceeded() {
        print("💚authenticationSucceeded")
        auth = true
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("💚authenticationFailed")
        auth = false
        
        switch errorCode {
        case 400:
            print("지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            print("지도 종료(API인증 키 오류)")
            break;
        case 403:
            print("지도 종료(API인증 권한 오류)")
            break;
        case 429:
            print("지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            print("지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("----> retry auth...")
                
                self.controller?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
}


// MARK: - Poi

extension KakaoMapCoordinator {
    
    ///LabelLayer는 manager을 통해 생성하고 manager 안에서 관리할 수 있다.
    ///특정 목적을 가진 Poi 를 묶어서 하나의 LabelLayer에 넣고 한꺼번에 Layer 자체를 표시하거나 숨길 수도 있다.
    func createLabelLayer() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        
        ///LabelLayer 설정
        ///competitionType - 다른 Poi와 경쟁하는 방법 결정 ( none, upper, same, lower, background )
        ///competitionUnit - 경쟁하는 단위 결정 ( poi, symbolFirst )
        ///orderType - competitionType이 same일 때( 자신과 같은 우선순위를 가진 poi와 경쟁할 때) 경쟁하는 기준이 된다. ( rank, closedFromLeftBottom )
        ///zOrder - 레이어의 렌더링 우선순위를 정의. 숫자가 높아질 수록 앞에 그려짐
        let layerOption = LabelLayerOptions(layerID: MapInfo.Poi.layerId, competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    ///PoiStyle도 manager를 통해 생성할 수 있고, styleID는 중복되면 안된다.
    ///PoiStyle은 한 개 이상의 레벨별 스타일(PerLevelStyle)로 구성된다.
    ///레벨별 스타일(PerLevelStyle)을 통해서 레벨마다 Poi가 어떻게 그려질 것인지를 지정한다.
    ///⭐️⭐️이 떄의 Level 이란? - 지도의 zoom 정도???
    ///PoiStyle은 정해진 개수의 preset을 미리 만들어두고, 상황에 따라 적절한 스타일을 선택하여 사용하는 방식으로 사용된다.
    ///-> 동적으로 계속 추가/삭제하는 형태의 사용은 적절하지 않다.
    func createPoiStyle() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        
        ///📍PoiIconStyle - symbol과 badge를 정의
        let defaultIconStyle = PoiIconStyle(symbol: UIImage(named: "pin")!, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let tappedIconStyle = PoiIconStyle(symbol: UIImage(named: "pin_activate")!, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        ///📍PoiTextLineStyle - 텍스트가 어떻게 표출될지 정의
        let textLineStyle = PoiTextLineStyle(textStyle: TextStyle(fontSize: 20, fontColor: .blue))
        let textStyle = PoiTextStyle(textLineStyles: [textLineStyle])
        textStyle.textLayouts = [PoiTextLayout.bottom]
        
        
        ///📍PerLevelPoiStyle - 레벨별로 스타일 지정할 수 있음
        ///level 0만 있으면 모든 레벨에서 해당 스타일이 적용됨
        ///📍 PoiStyle - PerLevelPoiStyle(레벨별로 스타일)들을 모아서 하나의 Poi 스타일을 생성

        //클릭되지 않았을 때 기본 poi 스타일
        let basicPerLevelStyle = PerLevelPoiStyle(iconStyle: defaultIconStyle, textStyle: textStyle, padding: 20, level: 0)
        let basicPoiStyle = PoiStyle(styleID: MapInfo.Poi.basicPoiPinStyleID, styles: [basicPerLevelStyle])
        //클릭되었을 때 poi 스타일
        let tappedPerLevelStyle = PerLevelPoiStyle(iconStyle: tappedIconStyle, textStyle: textStyle, padding: 20, level: 0)
        let tappedPoiStyle = PoiStyle(styleID: MapInfo.Poi.tappedPoiPinStyleID, styles: [tappedPerLevelStyle])
        
        
        manager.addPoiStyle(basicPoiStyle) //기본 poi 스타일
        manager.addPoiStyle(tappedPoiStyle) //클릭되었을 때 poi 스타일
    }
    
    
    
    func createPois() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: MapInfo.Poi.layerId)
        
        //탭 안 했을 때
        let basicPoiOption : PoiOptions = PoiOptions(styleID: MapInfo.Poi.basicPoiPinStyleID)
//        poiOption.rank = 0
        basicPoiOption.addText(PoiText(text: "광화문~~", styleIndex: 0))
        basicPoiOption.clickable = true
        
        //클릭되었을 때 poi 스타일
        let tappedPoiOption : PoiOptions = PoiOptions(styleID: MapInfo.Poi.tappedPoiPinStyleID)
        tappedPoiOption.addText(PoiText(text: "광화문~~", styleIndex: 0))
        tappedPoiOption.clickable = true
        
        
        let _ = layer?.addPois(option:basicPoiOption, at: testLocations)
        layer?.showAllPois()
    }
}


// MARK: - EventDelegate
extension KakaoMapCoordinator : KakaoMapEventDelegate{
    
    //poi를 탭했을 때
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        /// - parameter kakaoMap: Poi가 속한 KakaoMap
        /// - parameter layerID: Poi가 속한 layerID
        /// - parameter poiID:  Poi의 ID
        /// - parameter position: Poi의 위치
        
        print("✅✅✅poiDidTapped✅✅✅")
        
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: layerID)
        let poi = layer?.getPoi(poiID: poiID)
        
        if tappedPoi == poi{
            //기존에 선택되어있던게 있으면 basic스타일로 바꾸기
            poi?.changeStyle(styleID:MapInfo.Poi.basicPoiPinStyleID)
            parent.isBottomSheetOpen = false
            tappedPoi = nil
        }else {
            if let tappedPoi { //기존에 선택되어있던게 있으면 basic스타일로 바꾸기
                tappedPoi.changeStyle(styleID:MapInfo.Poi.basicPoiPinStyleID)
            }
            //새로 선택한 poi는 tappedStyle로
            poi?.changeStyle(styleID:MapInfo.Poi.tappedPoiPinStyleID)
            parent.isBottomSheetOpen = true
            tappedPoi = poi
        }

    }
    
    ///KakaoMap의 영역이 탭되었을 때 호출.
    ///-> tapped 되었던 스타일 basic으로 & bottom Sheet 내리기
    func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
        print("✅✅✅kakaoMapDidTapped✅✅✅")
    }
    
    
    /// 카메라 이동이 시작될 때 호출. cameraWillMove
    /// @objc optional func cameraWillMove(kakaoMap: KakaoMapsSDK.KakaoMap, by: MoveBy)
    ///


    /// 지도 이동이 멈췄을 때 호출.
    /// @objc optional func cameraDidStopped(kakaoMap: KakaoMapsSDK.KakaoMap, by: MoveBy)
    /// 현재 layer에 있던 모든 poi 숨기고 -> 지금 현재 위치값을 가져와서? 그 위치에 있는 주변  화장품 가게 검색??
    ///

    func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
        print("✅✅✅지도 이동 멈췄음,cameraDidStopped✅✅✅" )
        //그냥 이 위치에서 다시 검색에 대한 버튼 보여주기 showReloadStoreDataButton
        parent.showReloadStoreDataButton = true
        
        
//        let mapPoint = kakaoMap.getPosition(CGPoint(x: 100, y: 100))
//        print("💚mapPoint -> ", mapPoint)
        

//        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
//        let manager = view.getLabelManager()
//        let layer = manager.getLabelLayer(layerID: MapInfo.Poi.layerId)
//
//
//        //탭 안 했을 때
//        let basicPoiOption : PoiOptions = PoiOptions(styleID: MapInfo.Poi.basicPoiPinStyleID)
////        let _ = layer?.addPois(option:basicPoiOption, at: testLocations)
//        let _ = layer?.addPoi(option: basicPoiOption, at: mapPoint)

    }
}




