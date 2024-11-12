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
    
    //PhotosUI의 PhotosPicker에 의해 선택된 사진들
    @Published var selectedPhotos: [PhotosPickerItem] = []
    //이미지로 보여주기 위해 PhotosPickerItem을 UIImage로 바꾼 배열
    @Published var selectedImages: [UIImage] = []
    //매장리뷰
    @Published var storeReviewText = ""
    //제품리뷰
    @Published var productReviewText = ""
    //선택된 태그
    @Published var clickedTags : [String] = []
    //별점
    @Published var starRate : Int = 0
    
    
    private var myStoreRepository : any RepositoryType
    
    init(myStoreRepository : some RepositoryType) {
        self.myStoreRepository = myStoreRepository
        
        myStoreRepository.checkFileURL()
        myStoreRepository.checkSchemaVersion()
        
        transform()
    }
    
    func transform() {
        input
            .saveReview
            .sink { [weak self] storeInfo in
                guard let self else{return}
                self.saveReviewToRealm(storeInfo: storeInfo)
            }
            .store(in: &cancellables)
        
    }
    
    private func saveReviewToRealm(storeInfo : LocationDocument) {
        //TODO: 리뷰 잘 작성했는지 검증
        
        
        print("latitude💕💕💕", storeInfo.y)
        print("longitude💕💕💕", storeInfo.x)
        
        let reviewContent = ReviewContent(storeReviewText: storeReviewText, productReviewText: productReviewText, starRate: starRate)
        
        if let latitude = Double(storeInfo.y), let longitude = Double(storeInfo.x){
            print("latitude💕", latitude)
            print("longitude💕", longitude)
            let storeInfo = MyStoreInfo(savedAt: Date(), KakaoPaceName: storeInfo.placeName, KakaoPlaceID: storeInfo.id, KakaoPlaceUrl: storeInfo.placeUrl, latitude_y: latitude, longitude_x: longitude, addressName: storeInfo.addressName, roadAddressName: storeInfo.roadAddressName, phone: storeInfo.phone, categoryName: storeInfo.categoryName, isFlaged: false, isReviewed: false, reviewContent: reviewContent)

            print("✅reviewContent✅", reviewContent)
            print("✅storeInfo✅", storeInfo)
            myStoreRepository.createItem(storeInfo)
        }

    }
}


// MARK: - Input & Output
extension ReviewWriteViewModel {
    
    struct Input {
        let saveReview = PassthroughSubject<LocationDocument, Never>()
    }
    
    struct Output {
    }
}


// MARK: - Action
extension ReviewWriteViewModel{
    enum Action {
        case saveReview(storeInfo : LocationDocument)
    }
    
    func action (_ action:Action) {
        switch action {
        case .saveReview(let storeInfo):
            input.saveReview.send(storeInfo)
        }
    }
}

