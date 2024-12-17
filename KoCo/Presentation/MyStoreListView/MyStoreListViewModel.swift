//
//  MyStoreListViewModel.swift
//  KoCo
//
//  Created by 하연주 on 11/17/24.
//

import Foundation
import Combine

final class MyStoreListViewModel : ViewModelType {
    private var myStoreRepository : any RealmManagerType & MyStoreRealmMangerType
    
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    init(myStoreRepository : any RealmManagerType & MyStoreRealmMangerType) {
        self.myStoreRepository = myStoreRepository
        
        transform()
    }
    
    func transform() {
        input
            .getMyStoreList
            .sink { [weak self] mode in
                guard let self else{return}
                self.getMyStoreListFromRealm(mode: mode)
            }
            .store(in: &cancellables)
    }
    
    private func getMyStoreListFromRealm(mode : MyStoreMode) {
        let list = myStoreRepository.myStoreList(mode: mode)
        output.myStoreList = list
    }
    
    
}

// MARK: - Input & Output
extension MyStoreListViewModel {
    
    struct Input {
        let getMyStoreList = PassthroughSubject<MyStoreMode,Never>()
    }
    
    struct Output {
        var myStoreList : [MyStoreInfo] = []
    }
}


// MARK: - Action
extension MyStoreListViewModel{
    enum Action {
        case getMyStoreList(mode : MyStoreMode)
    }
    
    func action (_ action:Action) {
        switch action {
        case .getMyStoreList(let mode):
            input.getMyStoreList.send(mode)
        }
    }
}


