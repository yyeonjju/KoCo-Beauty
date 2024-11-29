//
//  LocationManager.swift
//  KoCo
//
//  Created by 하연주 on 10/1/24.
//

import Foundation
import CoreLocation


struct LocationCoordinate : Equatable {
    let longitude : Double
    let latitude : Double
}

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    ///1: CLLocationManagerDelegate 프로토콜 채택
    
    @Published var lastKnownLocation: LocationCoordinate?
    
    ///2 : CLLocationManager생성
    private var manager = CLLocationManager()
    
    override init() {
        super.init()
        self.manager.delegate = self
    }
    
    //locationManagerDidChangeAuthorization 시점에
    ///3-1 : iOS 위치 서비스 활성화 여부 체크
    func checkDeviceLocationAuthorization () {

        //해당경고 때문에 DispatchQueue.global().async
        //This method can cause UI unresponsiveness if invoked on the main thread. Instead, consider waiting for the `-locationManagerDidChangeAuthorization:` callback and checking `authorizationStatus` first.
        
        DispatchQueue.global().async {[weak self] in
            if CLLocationManager.locationServicesEnabled() {
                print("ios위치 서비스 사용할 수 있음! -> 디바이스의 위치 권한 체크")
                DispatchQueue.main.async {
                    self?.checkCurrentLocationAuthorization()
                }
            }else {
                
                print("ios위치 서비스 사용할 수 없음 -> 얼럿 띄워 iOS 설정으로 가도록")
                DispatchQueue.main.async {
//                    self?.outputIOSLocationServicesDisabled.value = ()
                }
            }
        }
        
    }

    ///3-2 : 기기의 위치 서비스 활성화 되어 있다면 실행
    ///현재 앱의 사용자 위치 권한 상태 확인
    func checkCurrentLocationAuthorization() {
        
//        manager.delegate = self
//        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Location notDetermined")
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            
        case .denied:
            print("Location denied")
            //임의 지역 띄워주기
            lastKnownLocation = LocationCoordinate(longitude: 126.9769, latitude: 37.5759)
//            CLLocationCoordinate2D(latitude: 37.5759, longitude: 126.9769)
            
        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            manager.startUpdatingLocation() //->⭐️ didUpdateLocations을 불러준다
//            lastKnownLocation = manager.location?.coordinate

            
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    ///3 : 사용자의 권한 상태가 변경이 될 때 + 앱 다시 시작할 때(인스턴스 재생성될 때)에도 실행이 된다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //기기의 위치 서비스 허용 여부부터 다시 확인 시작한다
        checkDeviceLocationAuthorization()
    }
    
    
    ///4-1  : 사용자 위치를 성공적으로 가지고 온 경우
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        lastKnownLocation = locations.first?.coordinate
        
        print("사용자 위치를 성공적으로 가지고 온 경우",#function)
        if let coordinate = locations.last?.coordinate {
            print("🧡coordinate", coordinate)
            
            //CLGeocoder 사용해서 감지된 사용자의 위치가 한국인지 검증
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr")
            geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), preferredLocale: locale) { [weak self] placemarks, error in
                guard let self, let placemarks else {return }
            
                if placemarks.last?.isoCountryCode == "KR" {
                    //사용자의 위치가 한국이 맞다면
                    self.lastKnownLocation = LocationCoordinate(longitude: coordinate.longitude, latitude: coordinate.latitude)
                } else {
                    //사용자의 위치가 한국이 아니라면 -> 디폴트 위치로
                    self.lastKnownLocation = LocationCoordinate(longitude: 126.9769, latitude: 37.5759)
                }
            }
            
           
        }
    
        manager.stopUpdatingLocation()
    }
    
    ///4-2 : 사용자의 위치를 가지고 오지 못했을 때
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("사용자의 위치를 가지고 오지 못했을 경우",#function)
//        view.makeToast("사용자의 위치를 가져올 수 없습니다.")
        //임의 지역 띄워주기
        lastKnownLocation = LocationCoordinate(longitude: 126.9769, latitude: 37.5759)
    }
}

