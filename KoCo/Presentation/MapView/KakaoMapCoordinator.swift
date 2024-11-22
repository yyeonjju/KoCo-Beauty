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
//    var first: Bool // 처음 위치로 카메라 이동시켜주기 위해
    var auth: Bool //카카오 sdk 인증
    

    var kakaoMap : KakaoMap?
    var controller: KMController?
    var container: KMViewContainer?
    var tappedPoi : Poi?
    
    init(_ kakaoMapView: KakaoMapView) {
        self.parent = kakaoMapView
//        first = true
        auth = false
        super.init()
    }
    
    let firstPosition = MapPoint(longitude: 126.9769, latitude: 37.5759)//광화문
    
    
    //KakaoMapView의 makeUIView 시점에
    func createController(_ view: KMViewContainer) {
        container = view
        controller = KMController(viewContainer: view)
        controller?.delegate = self
        print("🧡🧡🧡createController")
    }
    
    
    //addViewSucceeded ( 뷰가 성공적으로 추가 되었을 때 )
    func viewInit(viewName: String) {
        print("🧡🧡🧡viewInit")
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        view.eventDelegate = self
        kakaoMap = view
        
        createLabelLayer()
        createPoiStyle()
//        createPois()
    }
    
    //현재 위치 감지한 시점에 그 위치로 카메라 이동
    func moveCameraTo(_ mapPoint : MapPoint, completion : @escaping () -> Void) {
        // KakaoMap SDK의 MapPoint로 변환
        print("❤️❤️❤️카메라 이동❤️❤️❤️", mapPoint)
        print("❤️❤️❤️isMainThread❤️❤️❤️", Thread.isMainThread)
        
        // KakaoMap뷰를 가져와서 타입 캐스팅으로 KakaoMap 타입으로 변환
        if let mapView = controller?.getView(MapInfo.viewName) as? KakaoMap {
            // CameraUpdate를 사용하여 카메라 이동
            // target: 이동할 위치, zoomLevel: 확대 수준 1~20, 숫자가 클수록 확대됨
            let cameraUpdate = CameraUpdate.make(target: mapPoint, zoomLevel: 17, mapView: mapView)
            //카메가 이동 시 애니메이션
            mapView.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 500)) {[weak self] in
                guard let self else {return}
                completion()
            }
        }
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
    private func createLabelLayer() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        
        ///LabelLayer 설정
        ///competitionType - 다른 Poi와 경쟁하는 방법 결정 ( none, upper, same, lower, background )
        ///competitionUnit - 경쟁하는 단위 결정 ( poi, symbolFirst )
        ///orderType - competitionType이 same일 때( 자신과 같은 우선순위를 가진 poi와 경쟁할 때) 경쟁하는 기준이 된다. ( rank, closedFromLeftBottom )
        ///zOrder - 레이어의 렌더링 우선순위를 정의. 숫자가 높아질 수록 앞에 그려짐
        
        //✅ 화장품 매장에 대한 layer
        let layerOption = LabelLayerOptions(layerID: MapInfo.Poi.storeLayerID, competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        
        //✅ 선택된 myStore에 대한 layer
        let myStoreLayerOption = LabelLayerOptions(layerID: MapInfo.Poi.myStoreLayerID, competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10010)
        
        //✅ 현재 위치에 대한 layer
        let currentPointLayerOption = LabelLayerOptions(layerID: MapInfo.Poi.currentPointlayerID, competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10000)
        
        let _ = manager.addLabelLayer(option: layerOption)
        let _ = manager.addLabelLayer(option: myStoreLayerOption)
        let _ = manager.addLabelLayer(option: currentPointLayerOption)
    }
    
    ///PoiStyle도 manager를 통해 생성할 수 있고, styleID는 중복되면 안된다.
    ///PoiStyle은 한 개 이상의 레벨별 스타일(PerLevelStyle)로 구성된다.
    ///레벨별 스타일(PerLevelStyle)을 통해서 레벨마다 Poi가 어떻게 그려질 것인지를 지정한다.
    ///⭐️⭐️이 떄의 Level 이란? - 지도의 zoom 정도???
    ///PoiStyle은 정해진 개수의 preset을 미리 만들어두고, 상황에 따라 적절한 스타일을 선택하여 사용하는 방식으로 사용된다.
    ///-> 동적으로 계속 추가/삭제하는 형태의 사용은 적절하지 않다.
    private func createPoiStyle() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        
        
        //✅ 매장의 PoiStyle
        ///📍store PoiIconStyle - symbol과 badge를 정의
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
        let basicPerLevelStyle_level0 = PerLevelPoiStyle(iconStyle: defaultIconStyle, level: 0)
        let basicPerLevelStyle_leve15 = PerLevelPoiStyle(iconStyle: defaultIconStyle, textStyle: textStyle, padding: 20, level: 16)
        let basicPoiStyle = PoiStyle(styleID: MapInfo.Poi.basicPoiPinStyleID, styles: [basicPerLevelStyle_level0, basicPerLevelStyle_leve15])
        //클릭되었을 때 poi 스타일
        let tappedPerLevelStyle_level0 = PerLevelPoiStyle(iconStyle: tappedIconStyle, level: 0)
        let tappedPerLevelStyle_leve15 = PerLevelPoiStyle(iconStyle: tappedIconStyle, textStyle: textStyle, padding: 20, level: 16)
        let tappedPoiStyle = PoiStyle(styleID: MapInfo.Poi.tappedPoiPinStyleID, styles: [tappedPerLevelStyle_level0, tappedPerLevelStyle_leve15])

        
        //✅ 선택된 myStore에 대한 PoiStyle
        ///📍store PoiIconStyle - symbol과 badge를 정의
        let myStoreIconStyle = PoiIconStyle(symbol: UIImage(named: "myStore_pin")!, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let tappedMyStoreIconStyle = PoiIconStyle(symbol: UIImage(named: "myStore_pin_activate")!, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        
        ///📍PoiTextLineStyle - 텍스트가 어떻게 표출될지 정의
        let myStoreTextLineStyle = PoiTextLineStyle(textStyle: TextStyle(fontSize: 20, fontColor: .blue))
        let myStoreTextStyle = PoiTextStyle(textLineStyles: [myStoreTextLineStyle])
        myStoreTextStyle.textLayouts = [PoiTextLayout.bottom]
        
        ///📍PerLevelPoiStyle - 레벨별로 스타일 지정할 수 있음
        ///level 0만 있으면 모든 레벨에서 해당 스타일이 적용됨
        ///📍 PoiStyle - PerLevelPoiStyle(레벨별로 스타일)들을 모아서 하나의 Poi 스타일을 생성

        //클릭되지 않았을 때 기본 poi 스타일
        let myStorePerLevelStyle_level0 = PerLevelPoiStyle(iconStyle: myStoreIconStyle, level: 0)
        let myStorePerLevelStyle_leve15 = PerLevelPoiStyle(iconStyle: myStoreIconStyle, textStyle: myStoreTextStyle, padding: 20, level: 16)
        let myStoreBasicPoiStyle = PoiStyle(styleID: MapInfo.Poi.myStorePoiPinStyleID, styles: [myStorePerLevelStyle_level0, myStorePerLevelStyle_leve15])
        //클릭되었을 때 poi 스타일
        let tappedMyStorePerLevelStyle_level0 = PerLevelPoiStyle(iconStyle: tappedMyStoreIconStyle, level: 0)
        let tappedMyStorePerLevelStyle_leve15 = PerLevelPoiStyle(iconStyle: tappedMyStoreIconStyle, textStyle: myStoreTextStyle, padding: 20, level: 16)
        let tappedMyStorePoiStyle = PoiStyle(styleID: MapInfo.Poi.tappedMyStorePoiPinStyleID, styles: [tappedMyStorePerLevelStyle_level0, tappedMyStorePerLevelStyle_leve15])
        
        
        //✅ 현재 위치의 PoiStyle
        ///📍📍currentPoint PoiIconStyle ( with. transition)
        let currentPointIconStyle = PoiIconStyle(symbol: UIImage(named: "currentPoint")!, anchorPoint: CGPoint(x: 0.0, y: 0.5), transition: PoiTransition(entrance: .scale, exit: .scale), enableEntranceTransition: true, enableExitTransition: true)
        
        //현재 위치의 poi 스타일
        let currentPointPerLevelStyle = PerLevelPoiStyle(iconStyle: currentPointIconStyle, padding: 20, level: 0)
        let currentPointPoiStyle = PoiStyle(styleID: MapInfo.Poi.currentPointPoiPinStyleID, styles: [currentPointPerLevelStyle])
        
        
        
        manager.addPoiStyle(basicPoiStyle) //기본 poi 스타일
        manager.addPoiStyle(tappedPoiStyle) //클릭되었을 때 poi 스타일
        
        manager.addPoiStyle(myStoreBasicPoiStyle) //myStore 기본 poi 스타일
        manager.addPoiStyle(tappedMyStorePoiStyle) //myStore 클릭되었을 때 poi 스타일
        
        manager.addPoiStyle(currentPointPoiStyle)//현재 위치의 poi 스타일
        
    }
    
    func createSelectedMyStorePoi(myStore : LocationDocument) {
        guard let longitude = Double(myStore.x), let latitude = Double(myStore.y) else {return}
        
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let myStorelayer = manager.getLabelLayer(layerID: MapInfo.Poi.myStoreLayerID)
        
        //현재까지의 poi 없애기
        myStorelayer?.clearAllItems()
        
        //✅ 선택한 MyStore의 poi
        //표시하고 싶은 좌표
        let myStoreMapPoint = MapPoint(longitude: longitude, latitude: latitude)
        
        
        //poi별로 다른 텍스트를 적용해주기 위해
        
        //탭 안 했을 때의 스타일
        //⭐️ poi 클릭했을 때 poiID에 해당하는 매장 정보를 판단하기 위해 서버에서 받은 매장의 id가 poiID가 되도록 poiID직접 지정
        let basicPoiOption : PoiOptions = PoiOptions(
            styleID: MapInfo.Poi.myStorePoiPinStyleID,
            poiID: myStore.id
        )
        basicPoiOption.clickable = true
        basicPoiOption.addText(PoiText(
            text: myStore.placeName,
            styleIndex: 0
        ))
        
        let _ = myStorelayer?.addPoi(option: basicPoiOption, at: myStoreMapPoint, callback: { _ in
            print("poi 추가 완료")
        })
        myStorelayer?.showAllPois()
        
        //Poi가 생긴 후에 getPoi를 할 수 있음
//        let poi = myStorelayer?.getPoi(poiID: myStore.id)
//        tappedPoi = poi
    }
    
    func createPois(currentPoint : LocationCoordinate?, locations :  [LocationDocument]) {
        print("❤️createPois❤️")
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let storelayer = manager.getLabelLayer(layerID: MapInfo.Poi.storeLayerID)
        let currentPointlayer = manager.getLabelLayer(layerID: MapInfo.Poi.currentPointlayerID)
        
        
        //✅ 현재 위치의 Poi
        let currentPointPoiOption : PoiOptions = PoiOptions(styleID: MapInfo.Poi.currentPointPoiPinStyleID)
        if let currentPoint {
            currentPointlayer?.clearAllItems()
            let _ = currentPointlayer?.addPoi(option: currentPointPoiOption, at: MapPoint(longitude: currentPoint.longitude, latitude: currentPoint.latitude))
            currentPointlayer?.showAllPois()
        }
        
        
        

        //✅ 매장의 poi
        //현재까지의 poi 없애기
        storelayer?.clearAllItems()
        
        //표시하고 싶은 좌표 리스트
        let mapPointList = locations.map {
            MapPoint(longitude: Double($0.x)!, latitude: Double($0.y)!)
        }
        
        //poi별로 다른 텍스트를 적용해주기 위해
        let textAddedPoiOptions = mapPointList.enumerated().map{
            //탭 안 했을 때의 스타일
            //⭐️ poi 클릭했을 때 poiID에 해당하는 매장 정보를 판단하기 위해 서버에서 받은 매장의 id가 poiID가 되도록 poiID직접 지정
            let basicPoiOption : PoiOptions = PoiOptions(styleID: MapInfo.Poi.basicPoiPinStyleID ,poiID: locations[$0.offset].id)
            basicPoiOption.clickable = true
            basicPoiOption.addText(PoiText(text: locations[$0.offset].placeName, styleIndex: 0))
            return basicPoiOption
        }

        //options에 [PoiOptions] 넣을 때는 at과 요소 하나하나 매칭되도록 동일한 length로 구성
        let _ = storelayer?.addPois(options:textAddedPoiOptions, at: mapPointList){[weak self] _ in
            guard let self else {return}
            parent.isPoisAdding = false
        }
        storelayer?.showAllPois()
        
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
    
        
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: layerID)
        let poi = layer?.getPoi(poiID: poiID)
        
        print("❤️❤️❤️ poiDidTapped ❤️❤️❤️", Thread.isMainThread)
        print("❤️❤️❤️ layerID ❤️❤️❤️", layerID)
        print("❤️❤️❤️ tappedPoi ❤️❤️❤️", tappedPoi?.itemID)
        print("❤️❤️❤️ poi ❤️❤️❤️", poi?.itemID)
        
 
        
        //PoiOptions 세팅할 때 매장id로 지정해주었던 poiID(매장의 id)로 lastTappedStoreID 값 업데이트
        parent.lastTappedStoreID = poiID
        
        let basicPoiPinStyleID = layerID == MapInfo.Poi.storeLayerID ? MapInfo.Poi.basicPoiPinStyleID : MapInfo.Poi.myStorePoiPinStyleID
        let tappedPoiPinStyleID = layerID == MapInfo.Poi.storeLayerID ? MapInfo.Poi.tappedPoiPinStyleID : MapInfo.Poi.tappedMyStorePoiPinStyleID
        
        //poi 스타일 변경
        if tappedPoi == poi{
            //기존에 선택되어있던게 있으면 basic스타일로 바꾸기
            poi?.changeStyle(styleID:basicPoiPinStyleID)
            parent.isBottomSheetOpen = false
            tappedPoi = nil
        }else {
            if let tappedPoi{
                //기존에 선택되어 있었던 tappedPoi가 어느 레이어의 poi인지에 따라 basic스타일로 바꾸기
                tappedPoi.changeStyle(
                    styleID: tappedPoi.layerID == MapInfo.Poi.storeLayerID ? MapInfo.Poi.basicPoiPinStyleID : MapInfo.Poi.myStorePoiPinStyleID
                )
            }
            
            //새로 선택한 poi는 tappedStyle로
            poi?.changeStyle(styleID:tappedPoiPinStyleID)
            parent.isBottomSheetOpen = true
            tappedPoi = poi
        }
        
//        //poi를 지도의 중앙으로할 수 있도록 카메라 이동
//        if let PoiPosition = poi?.position {
//            moveCameraToCurrentLocation(PoiPosition)
//        }
       

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
        print("✅✅✅지도 이동 멈췄음,cameraDidStopped✅✅✅", kakaoMap.zoomLevel )
        // '이 위치에서 다시 검색' 버튼 보여주기 showReloadStoreDataButton
        parent.showReloadStoreDataButton = true

        // 내 스크린의 중심점 CGPoint에 대한 카카오맵의 좌표 가져오기
        let cameraCenterMapPoint : MapPoint = kakaoMap.getPosition(CGPoint(x: ScreenSize.width/2, y: ScreenSize.height/2))
        //이동한 카메라 상에서 내 스크린의 중심점 좌표를 저장해두기
        //( '이 위치에서 검색' 버튼 클릭 시 좌표 활용을 위해 )
        parent.currentCameraCenterCoordinate =         LocationCoordinate(longitude: cameraCenterMapPoint.wgsCoord.longitude, latitude: cameraCenterMapPoint.wgsCoord.latitude)

    }
}




