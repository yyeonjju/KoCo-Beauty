//
//  MapView.swift
//  KoCo
//
//  Created by 하연주 on 9/24/24.
//

import SwiftUI

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm = MapViewModel()
    
    var body: some View {
        VStack {
            Text("\(locationManager.lastKnownLocation)")
            
            ForEach(vm.output.searchLocations, id: \.id ) { location in
                Text("\(location.placeName) - \(location.categoryName)")
            }
            
        }
//        .onChange(of: locationManager.lastKnownLocation?.latitude, initial: false) { oldValue, newValue in
//            print("17 이후")
//        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
            print("🎀🎀내 위치 감지해서 or 디폴트 위치 설정으로 lastKnownLocation 바뀌었다🎀🎀")
            //1 : 카카오 맵의 위치 이동 ( 현재 나의 위치로 )
            
            //2 : 이 위치에 맞는 화장품 가게 검색⭐️⭐️. 하고 핀 (poi) 꽃기
            guard let newValue else {return }
            vm.action(.fetchStoreData(location: newValue))
            
        }
        .onChange(of: vm.output.searchLocations) { locations in
            
            //카카오 맵에 locations 핀 띄워야한다
            print("⭐️ 카카오맵에 핀 띄우기 ")
        }
        


    }
}

#Preview {
    MapView()
}

//TODO: 카카오맵에 반영
//locationManager.lastKnownLocation 위치 받은걸로 맵뷰 띄워주기
//근데 위치 바꾼걸 감지하는건 어느 클래스에서 해주징..


//✅LocationManager에서 현재위치 감지했을 때 -> 화장품 가게 검색 call
//다국어 세팅
//카카오 맵 쓸 수 있게 세팅


//지도 이동해서 지도 기준 center가 이동했을 대 -> 화장품 가게 검색 call
// or
//이 위치로 다시 검색하기 버튼 놓고




