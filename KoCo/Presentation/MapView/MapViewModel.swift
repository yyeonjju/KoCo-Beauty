//
//  MapViewModel.swift
//  KoCo
//
//  Created by 하연주 on 10/1/24.
//

import Foundation
import Combine

final class MapViewModel : ObservableObject, ViewModelType {
    private var myStoreRepository : any RepositoryType & MyStoreType
    
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    @Published var draw : Bool = false
    @Published var isBottomSheetOpen : Bool = false
    @Published var showReloadStoreDataButton : Bool = false
    
    //현재 위치 감지에 따른 카메라 이동
    @Published var isCameraMoving : Bool = false
    @Published var cameraMoveTo : LocationCoordinate?
    
    //현재위치 기반 화장품 매장 검색 결과에 따른 poi 추가
    @Published var isPoisAdding : Bool = false
    @Published var LocationsToAddPois : [LocationDocument] = []
    
    //카메라 이동이 멈춘 시점에 업데이트 되는 현재 내 스크린의 중심값에 대한 지도 좌표
    @Published var currentCameraCenterCoordinate : LocationCoordinate? = nil
    
    //지도의 poi 탭했을 때 그 매장의 id (==poiID)
    @Published var lastTappedStoreID : String = "" {
        didSet{
            action(.setupTappedStoreData(id: lastTappedStoreID))
        }
    }
    //탭한 매장의 정보
    var lastTappedStoreData : LocationDocument? {
        didSet{
            guard let lastTappedStoreData else{return }
            setupCurrentStoreStatus(id: lastTappedStoreData.id)
        }

    }
    //탭한 매장 플래그 여부
    @Published var isTappeStoreFlaged : Bool = false
    //탭한 매장 리뷰 여부
    var isTappeStoreReviewed : Bool = false
    
    
    //MyStoreListView에서 아이템 선택해서 MapView로 넘어왔을 때 맵에 띄워주기 위해
    @Published var selectedMyStoreAddingOnMap : Bool = false
    @Published var selectedMyStoreID : String?
    @Published var selectedMyStore : MyStoreInfo? {
        didSet{
            guard let myStore = selectedMyStore else {return }
            
            selectedMyStoreID = selectedMyStore?.KakaoPlaceID
            
            lastTappedStoreData = myStore.convertToLocationDocument()
        }
    }

    
    
    init(myStoreRepository : any RepositoryType & MyStoreType) {
        self.myStoreRepository = myStoreRepository
        
        transform()
    }
    
    func transform() {
        input
            .fetchStoreData
            .sink { [weak self] location in
                guard let self else{return}
                self.getStoreData(location: location)
            }
            .store(in: &cancellables)
        
        input
            .toggleIsFlagedStatus
            .sink { [weak self] id,to in
                guard let self, let lastTappedStoreData else{return}
                myStoreRepository.toggleFlag(storeID: id, to: to, storeData: lastTappedStoreData)
                setupCurrentStoreStatus(id: id)
            }
            .store(in: &cancellables)
        
        input.setupTappedStoreData
            .sink { [weak self] id in
                guard let self else{return}
                setupTappedStoreData(id: id)
            }
            .store(in: &cancellables)
    }
    
    private func setupTappedStoreData(id : String) {
        if let storeDataAmongSearchLocations = output.searchLocations.first(where: {
            $0.id == id
        }) {
            //검색한 위치 중에 있으면
            lastTappedStoreData = storeDataAmongSearchLocations
        } else if let selectedMyStore, selectedMyStore.KakaoPlaceID == id {
            //플래그된매장, 리뷰작성한 매장 리스트 페이지에서 선택한 매장이라서 지도에 뜬 매장이라면
            lastTappedStoreData = selectedMyStore.convertToLocationDocument()
        } else {
            lastTappedStoreData = nil
        }
    }
    
    private func setupCurrentStoreStatus(id : String) {
        if let myStoreInfo = myStoreRepository.myStore(for: id) {
            isTappeStoreFlaged = myStoreInfo.isFlaged
            isTappeStoreReviewed = myStoreInfo.isReviewed
            
        }else {
            isTappeStoreFlaged = false
            isTappeStoreReviewed = false
        }
    }
    
    // "현재 지도에서 다시 검색" 버튼 눌렀을 때
    // & 위치 권한 확인하고 처음 현재 위치 파악했을 때
    private func getStoreData(location : LocationCoordinate) {
        print("⭐️ 스토어 검색해야해", location)
        
        NetworkManager.shared.searchStoreData(query: "화장품", location : location)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self else { return }
                    switch value {
                    case .failure:
                        print("⭐️receiveCompletion - failure")
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] value in
                    guard let self else { return }
                    print("⭐️receiveValue - value", value.documents)
                    
                    print("⭐️receiveValue - value")
                    dump(value.documents)
                    
                    
                    self.output.searchLocations = value.documents

                })
            .store(in: &cancellables)
    }
    
}

// MARK: - Input & Output
extension MapViewModel {
    
    struct Input {
        let fetchStoreData = PassthroughSubject<LocationCoordinate, Never>()
        let toggleIsFlagedStatus = PassthroughSubject<(String,Bool), Never>()
        let setupTappedStoreData = PassthroughSubject<String, Never>()
        
        let viewOnTask = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var searchLocations : [LocationDocument] = []
    }
}


// MARK: - Action
extension MapViewModel{
    enum Action {
        //주변 매장 검색을 위해
        //location에서 권한에 따라 불러온 위치 & "현재 지도에서 검색" 버튼 눌렀을 때
        case fetchStoreData(location : LocationCoordinate)
        case toggleIsFlagedStatus(id : String, to : Bool)
        case setupTappedStoreData(id : String)
    }
    
    func action (_ action:Action) {
        switch action {
        case .fetchStoreData(let location) :
            input.fetchStoreData.send(location)
        case .toggleIsFlagedStatus(let id, let to) :
            input.toggleIsFlagedStatus.send((id, to))
        case .setupTappedStoreData(let id) :
            input.setupTappedStoreData.send(id)
            
        }
    }
}

