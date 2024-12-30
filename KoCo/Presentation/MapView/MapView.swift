//
//  MapView.swift
//  KoCo
//
//  Created by 하연주 on 9/24/24.
//

import SwiftUI
import Combine

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm = DIContainer.makeMapViewModel()
    
    @State private var reviewWritePageShown = false
    @State private var isMenuSpread = false
    @State private var toastState : Toast.ToastState = .init(message: "", isShowing: false)
    
    var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            kakaoMap
            
            if vm.showReloadStoreDataButton {
                reloadStoreDataButton
            }
            
            menuButtonSection
           
            bottomSheet
        }
        .fullScreenCover(isPresented: $reviewWritePageShown){
            if let tappedStoreData = vm.lastTappedStoreData {
                let operation : Operation = vm.isTappeStoreReviewed ? .read : .create
                ReviewWriteView(isPresented: $reviewWritePageShown, operation : operation, storeInfo: tappedStoreData)
            }
        }
//        .toast(message: vm.output.requestErrorOccur?.rawValue ?? "-" ,
//               position: .top ,
//               isShowing: 
//                Binding(
//                    get: {vm.output.requestErrorOccur != nil},
//                    set: {if !$0 {vm.output.requestErrorOccur = nil}  }
//                ),
//               duration : Toast.long
//        )
//        .toast(message: toastState.message,position: .top ,isShowing: $toastState.isShowing, duration : Toast.long)
//        .onChange(of: vm.output.requestErrorOccur) { error in
//            guard let error else {return}
//            toastState = Toast.ToastState(message: error.rawValue, isShowing: true)
//            vm.output.reviewValidationErrorOccur = nil
//        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
//            print("내 위치 감지해서 or 디폴트 위치 설정으로 lastKnownLocation 바뀌었다 -> ", newValue)
            
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
        .onChange(of: vm.selectedMyStore) { myStore in
            //플래그, 리뷰한 리스트 화면에서 탭한 매장, dismiss되면서 binding된 데이터
            vm.isBottomSheetOpen = true
            vm.selectedMyStoreAddingOnMap = true
        }
        .onChange(of: reviewWritePageShown) { isPresented in
            //리뷰 작성하고 map으로 돌아왔을 때 리뷰 작성여부 업데이트 위해
            if !isPresented {
                vm.action(.setupTappedStoreData(id: vm.lastTappedStoreID))
            }
        }
        
        .onChange(of: vm.lastTappedStoreData) { storeData in
            //매장 이름을 네이버 이미지 검색 api 로 검색해서 bottomSheet에 이미지 로드
//            print("lastTappedStoreID - 이미지 검색 시점??")
            guard let storeData else{return }
            vm.action(.searchStoreImage(query: storeData.placeName))
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
            currentCameraCenterCoordinate : $vm.currentCameraCenterCoordinate,
            lastTappedStoreID : $vm.lastTappedStoreID,
            selectedMyStoreAddingOnMap : $vm.selectedMyStoreAddingOnMap,
            lastTappedStoreData : vm.lastTappedStoreData,
            selectedMyStoreID : vm.selectedMyStoreID
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
    
    var menuButtonSection : some View {
        VStack(alignment : .trailing) {
            
            HStack{
                Spacer()
                
                Button {
                    withAnimation{
                        isMenuSpread.toggle()
                    }
                } label : {
                    CircleMenuView(
                        iconSize: CGSize(width: 20, height: 20),
                        icon : Assets.SystemImage.ellipsis
                    )
                }
                .padding(.top)
                .padding(.trailing, 20)
            }

            
            NavigationLink {
                MyStoreListView(mode: .reviewExist, selectedMyStore : $vm.selectedMyStore)
                    .navigationTitle("리뷰 작성한 매장")
            } label : {
                CircleMenuView(
                    icon :  Assets.SystemImage.menucard
                )
            }
            .padding(.trailing, 20)
            .opacity(isMenuSpread ? 1 : 0)
            .offset(y : isMenuSpread ? 0 : -30)

            
            NavigationLink {
                MyStoreListView(mode: .flaged, selectedMyStore : $vm.selectedMyStore)
                    .navigationTitle("플래그된 매장")
            } label : {
                CircleMenuView(
                    iconSize: CGSize(width: 16, height: 16),
                    icon :  Assets.SystemImage.flag
                )
            }
            .padding(.trailing, 20)
            .opacity(isMenuSpread ? 1 : 0)
            .offset(y : isMenuSpread ? 0 : -60)

            
            Spacer()
        }
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
                .shadow(color: Assets.Colors.black.opacity(0.4), radius: 3)
                
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
        
        return VStack {
            if let tappedStoreData = vm.lastTappedStoreData {
//                let categories = tappedStoreData.categoryName.components(separatedBy: ">")
//                let categoryText = categories.count>1 ? categories[categories.count-1] : "-"
                
                StoreInfoHeaderView(
                    placeName: tappedStoreData.placeName,
                    categoryText: tappedStoreData.categoryName,
                    distance: tappedStoreData.distance,
                    addressName: tappedStoreData.addressName
                )
                
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
                    ForEach(0..<3) { index in
                        
                        let link = index < vm.output.searchedStoreImages.count
                        ? vm.output.searchedStoreImages[index].link
                        : nil
                        
                        CacheAsyncImage(url: link, width: 100)
                            .padding(2)
//                        BaisicAsyncImage(url: link, width: 100)
//                            .padding(2)
                        
                        
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
                        Text(vm.isTappeStoreReviewed ? "작성한 리뷰 보기" : "리뷰 기록")
                            .asNormalOutlineText(isFilled : true)
                    }
                    
                    Spacer()
                    
                    Button {
                        vm.action(.toggleIsFlagedStatus(id : tappedStoreData.id,to: !vm.isTappeStoreFlaged))
                    } label : {
                        
                        let flag = vm.isTappeStoreFlaged 
                        ? Assets.SystemImage.flagFill
                        : Assets.SystemImage.flag
                        
                        let flagColor = tappedStoreData.placeName == "네이처리퍼블릭 메트로문래역점"
                        ? Assets.Colors.pointPink
                        : Assets.Colors.skyblue
                        
                        flag
                            .resizable()
                            .foregroundColor(flagColor)
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




