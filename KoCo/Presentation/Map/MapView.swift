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
    
    @State private var isCameraMoving : Bool = false
    @State private var cameraMoveTo : LocationCoordinate?
    
    @State private var isPoisAdding : Bool = false
    @State private var LocationsToAddPois : [LocationDocument] = []
    
    var body: some View {
        ZStack {
            KakaoMapView(draw: $vm.draw, isBottomSheetOpen : $vm.isBottomSheetOpen, showReloadStoreDataButton : $vm.showReloadStoreDataButton,isCameraMoving : $isCameraMoving , cameraMoveTo : $cameraMoveTo, isPoisAdding : $isPoisAdding, LocationsToAddPois : $LocationsToAddPois)
                .onAppear{
                    vm.draw = true
                }
                .onDisappear{
                    vm.draw = false
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            if vm.showReloadStoreDataButton {
                VStack{
                    Button {
                        print("이 위치에서 검색 버튼 눌렸다!!")
                    }label : {
                        HStack{
                            Image(systemName: "arrow.clockwise")
                            Text("이 위치에서 검색")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.skyblue)
                        .foregroundStyle(.white)
                        .font(.system(size: 13))
                        .cornerRadius(20)
                        
                    }
                    
                    Spacer()
                }
            }
           
            
            
            BottomSheetView(isOpen: $vm.isBottomSheetOpen, maxHeight: 300, showIndicator:true,  isIgnoreedSafeArea : true, minHeightRatio : 0) {
                
                Text("BottomSheetView")
            }
            
        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
            print("🎀🎀내 위치 감지해서 or 디폴트 위치 설정으로 lastKnownLocation 바뀌었다🎀🎀 -> ", newValue)
            
            //일시적 fix
            // viewInit 되기 전에 현재 위치로 카메라 이동 함수가 실행되면 작동하지 않으므로 타이밍 미루기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard let newValue else {return }
                //1 : 카카오 맵의 카메라 위치 이동 ( 현재 나의 위치 or 위치 권한 없다면 임의의 위치로)
                isCameraMoving = true
                cameraMoveTo = newValue
                
                
                //2 : 이 위치에 맞는 화장품 가게 검색. 하고 핀 (poi) 꽃기
                vm.action(.fetchStoreData(location: newValue))
            }
        }
        .onChange(of: vm.output.searchLocations) { locations in
            
            //카카오 맵에 locations 핀 띄워야한다
            print("⭐️ 카카오맵에 핀 띄우기 ")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isPoisAdding = true
                LocationsToAddPois = locations
            }
        }
        


    }
}

#Preview {
    MapView()
}




