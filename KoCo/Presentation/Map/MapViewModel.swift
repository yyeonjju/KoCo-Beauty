//
//  MapViewModel.swift
//  KoCo
//
//  Created by 하연주 on 10/1/24.
//

import Foundation
import Combine

final class MapViewModel : ObservableObject, ViewModelType {
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    @Published var draw : Bool = false
    @Published var isBottomSheetOpen : Bool = false
    @Published var showReloadStoreDataButton : Bool = false
    
    init() {
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
    }
    

    
    
    
    // "현재 지도에서 다시 검색" 버튼 눌렀을 때
    // & 위치 권한 확인하고 처음 현재 위치 파악했을 때
    func getStoreData(location : LocationLonLat) {
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
                    self.output.searchLocations = value.documents

                })
            .store(in: &cancellables)
    }
    
}

// MARK: - Input & Output
extension MapViewModel {
    
    struct Input {
        let fetchStoreData = PassthroughSubject<LocationLonLat, Never>()
        
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
        case fetchStoreData(location : LocationLonLat)
    }
    
    func action (_ action:Action) {
        switch action {
        case .fetchStoreData(let location) :
            input.fetchStoreData.send(location)
        }
    }
}

