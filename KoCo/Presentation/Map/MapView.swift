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
            KakaoMapView(draw: $vm.draw, isBottomSheetOpen : $vm.isBottomSheetOpen, showReloadStoreDataButton : $vm.showReloadStoreDataButton)
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




