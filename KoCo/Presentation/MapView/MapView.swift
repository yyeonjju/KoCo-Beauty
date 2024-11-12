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
    
    @State private var reviewWritePageShown = false
    
    var body: some View {
        ZStack {
            kakaoMap
            
            if vm.showReloadStoreDataButton {
                reloadStoreDataButton
            }
           
            bottomSheet
        }
        .fullScreenCover(isPresented: $reviewWritePageShown){
            if let tappedStoreData = vm.output.searchLocations.first(where: {
                $0.id == vm.lastTappedStoreID
            }){
                ReviewWriteView(isPresented: $reviewWritePageShown, storeInfo: tappedStoreData)
            }
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
//        .onChange(of: vm.lastTappedStoreID) { newValue in
//            //매장 이름을 네이버 이미지 검색 api 로 검색해서 bottomSheet에 이미지 로드
//        }
        


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
            currentCameraCenterCoordinate : $vm.currentCameraCenterCoordinate,
            lastTappedStoreID : $vm.lastTappedStoreID
        )
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
                
                //BottomSheet 올라와 있으면 내리기
                vm.isBottomSheetOpen = false
            }label : {
                HStack{
                    Assets.SystemImage.arrowClockwise
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
        BottomSheetView(isOpen: $vm.isBottomSheetOpen, maxHeight: 320, showIndicator:true,  isIgnoredSafeArea : true, minHeightRatio : 0) {
            
            bottomSheetContent
        }
    }
    
    var bottomSheetContent : some View {
        let tappedStoreData = vm.output.searchLocations.first {
            $0.id == vm.lastTappedStoreID
        }
        let category = tappedStoreData?.categoryName.components(separatedBy: ">") ?? ["화장품"]
        let categoryText = category[category.count-1]
        
        return VStack {
            if let tappedStoreData {
                HStack {
                    //매장이름
                    Text(tappedStoreData.placeName)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.skyblue)
//                        .padding()
                    //카테고리 이름
                    Text(categoryText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(.bottom,4)
                
                HStack{
                    Text(tappedStoreData.distance + "m")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text(tappedStoreData.addressName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(.bottom,4)
                
                HStack {
                    if !tappedStoreData.phone.isEmpty{
                        Text(tappedStoreData.phone)
                            .font(.system(size: 14))
                        Assets.SystemImage.phoneFill
                        
                        Spacer()
                    }
                }
                .padding(.bottom,4)
                
                HStack{
                    ForEach(0..<3) { item in
                        BaisicAsyncImage(url: "https://search.pstatic.net/common/?type=b150&src=http://post.phinf.naver.net/MjAyMjA0MTVfMjQ2/MDAxNjUwMDE5NDA4Mjgw.CgQJxztRuJfn4ihLu4eKU7dPasRUnQsy2x5owX4ci-gg.1Snzbi21dWabljj5SyfPUDZI-5NT-U7P32CgewqNSYgg.JPEG/Io7UGYEjtHnI1ViGT2_YIhkgFhWI.jpg", width: 100)
                        .padding(2)
                    }
                }
                .padding(.bottom,4)

                
                HStack{
                    NavigationLink{
                        StoreWebView(placeUrl: tappedStoreData.placeUrl)
                            .navigationTitle(tappedStoreData.placeName)
                        
                    }label: {
                        Text("> 매장 정보 자세히 보기")
                            .font(.system(size: 14))
                            .underline()
                            .foregroundStyle(.black)

                    }

                    Spacer()
                }
                .padding(.bottom,4)
                
                Divider()
                    .foregroundColor(.gray)
                    .padding(.bottom,4)
                
                HStack(alignment : .center){
                    Button {
                        reviewWritePageShown = true
                    }label : {
                        Text("리뷰 기록")
                            .asNormalOutlineText(isFilled : true)
                    }
                    
                    Spacer()
                    
                    Button {
                        print("플래그 버튼 눌림")
                    } label : {
                        Assets.SystemImage.flag
                            .resizable()
                            .foregroundColor(.skyblue)
                            .frame(width: 20, height: 24)
                    }
                }
//                .background(.gray)

                
            }else {
                Text("매장을 선택해주세요.")
            }

        }
        .padding(.horizontal)
    }
}


#Preview {
    MapView()
}




