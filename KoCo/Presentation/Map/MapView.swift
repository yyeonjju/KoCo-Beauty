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
        ZStack {
            kakaoMap
            
            if vm.showReloadStoreDataButton {
                reloadStoreDataButton
            }
           
            bottomSheet
        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
            print("🎀🎀내 위치 감지해서 or 디폴트 위치 설정으로 lastKnownLocation 바뀌었다🎀🎀 -> ", newValue)
            
            //일시적 fix
            // viewInit 되기 전에 현재 위치로 카메라 이동 함수가 실행되면 작동하지 않으므로 타이밍 미루기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard let newValue else {return }
                //1 : 카카오 맵의 카메라 위치 이동 ( 현재 나의 위치 or 위치 권한 없다면 임의의 위치로)
                vm.isCameraMoving = true
                vm.cameraMoveTo = newValue
                
                
                //2 : 이 위치에 맞는 화장품 가게 검색. 하고 핀 (poi) 꽃기
                vm.action(.fetchStoreData(location: newValue))
            }
        }
        .onChange(of: vm.output.searchLocations) { locations in
            
            //카카오 맵에 locations에 대한 poi 핀 띄우기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                vm.isPoisAdding = true
                vm.LocationsToAddPois = locations
            }
        }
        


    }
}


extension MapView {
    var kakaoMap : some View {
        KakaoMapView(
            draw: $vm.draw,
            isBottomSheetOpen : $vm.isBottomSheetOpen,
            showReloadStoreDataButton : $vm.showReloadStoreDataButton,
            isCameraMoving : $vm.isCameraMoving ,
            cameraMoveTo : $vm.cameraMoveTo,
            isPoisAdding : $vm.isPoisAdding,
            LocationsToAddPois : $vm.LocationsToAddPois,
            currentCameraCenterCoordinate : $vm.currentCameraCenterCoordinate)
            .onAppear{
                vm.draw = true
            }
            .onDisappear{
                vm.draw = false
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var reloadStoreDataButton : some View {
        VStack{
            Button {
                guard let currentCameraCenterCoordinate = vm.currentCameraCenterCoordinate else {return }
                vm.action(.fetchStoreData(location: currentCameraCenterCoordinate))
            }label : {
                HStack{
                    Image(systemName: "arrow.clockwise")
                    Text("이 위치에서 검색")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.skyblue)
                .foregroundStyle(.white)
                .font(.system(size: 13))
                .cornerRadius(20)
                .padding(.top)
                
            }
            
            Spacer()
        }
    }
    
    var bottomSheet : some View {
        BottomSheetView(isOpen: $vm.isBottomSheetOpen, maxHeight: 300, showIndicator:true,  isIgnoreedSafeArea : true, minHeightRatio : 0) {
            
            Text("BottomSheetView")
        }
    }
}


#Preview {
    MapView()
}




