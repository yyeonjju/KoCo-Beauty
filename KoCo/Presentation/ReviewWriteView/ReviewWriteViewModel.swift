//
//  ReviewWriteViewModel.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import PhotosUI

final class ReviewWriteViewModel : ObservableObject, ViewModelType {
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    private var myStoreRepository : any RepositoryType
    
    init(myStoreRepository : some RepositoryType) {
        self.myStoreRepository = myStoreRepository
        
        myStoreRepository.checkFileURL()
        myStoreRepository.checkSchemaVersion()
        
        let item = MyStoreInfo(savedAt: Date(), KakaoPaceName: "테스트 KakaoPaceName", KakaoPlaceID: "테스트 KakaoPlaceID", KakaoPlaceUrl: "테스트 KakaoPlaceUrl", latitude_y: 37.5759, longitude_x: 126.9769, addressName: "테스트 addressName", roadAddressName: "테스트 roadAddressName", phone: "테스트 phone", categoryName: "테스트 categoryName", isFlaged: false, isReviewed: false, reviewContent: nil)

        myStoreRepository.createItem(item)
        
        transform()

    }
    
    func transform() {
        
    }
}


// MARK: - Input & Output
extension ReviewWriteViewModel {
    
    struct Input {
    }
    
    struct Output {
    }
}


// MARK: - Action
extension ReviewWriteViewModel{
    enum Action {

    }
    
    func action (_ action:Action) {
    }
}

