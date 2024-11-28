//
//  ReviewWriteViewModel.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import Combine
//import UIKit
import SwiftUI
import PhotosUI
import RealmSwift

final class ReviewWriteViewModel : ViewModelType {
    private var myStoreRepository : any RepositoryType & MyStoreType
    
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
    @Published var clickedTags : [Int] = []
    //별점
    @Published var starRate : Int = 0

    
    init(myStoreRepository : any RepositoryType & MyStoreType) {
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
        
        input
            .getReviewForID
            .sink { [weak self] storeID in
                guard let self else{return}
                self.getReviewFromRealm(storeID: storeID)
            }
            .store(in: &cancellables)
        
    }
    
    private func getReviewFromRealm(storeID : String) {
        guard let myStore = myStoreRepository.myStore(for: storeID) else {
            output.errorOccur = .noStore
            print("🚨🚨🚨noStore🚨🚨🚨")
            return
        }
        
        guard let reviewContent = myStore.reviewContent else {
            output.errorOccur = .noReviewContent
            print("🚨🚨🚨noReviewContent🚨🚨🚨")
            return
        }
        
        //리뷰 컨텐츠 뷰에 셋업
        //매장 리뷰
        self.storeReviewText = reviewContent.storeReviewText
        //제품 리뷰
        self.productReviewText = reviewContent.productReviewText
        //태그
        self.clickedTags =  Array(reviewContent.reviewTags).map{$0.rawValue}
        //별점
        self.starRate = reviewContent.starRate
        //사진 기록
        for fileName in reviewContent.photoFileNames {
            let uiImage = ImageSavingManager.loadImageFromDocument(filename: fileName)
            self.selectedImages.append(uiImage ?? UIImage())
        }
        
        
    }
    
    private func saveReviewToRealm(storeInfo : LocationDocument) {
        
        print("latitude💕💕💕", storeInfo.y)
        print("longitude💕💕💕", storeInfo.x)
        print("🧡 클릭된 태그 --> ", clickedTags)
        
        let currentDate = Date()
        

        //✅ 태그
        //[string] -> [ReviewTag]
        let reviewTags = clickedTags.map{ReviewTagItem(rawValue:$0) ?? .recommend}
        //array 형태의 태그 리스트 -> RealmSwift.List 형태
        let realmListTagIDs : RealmSwift.List<ReviewTagItem> = RealmSwift.List()
        realmListTagIDs.append(objectsIn: reviewTags)
        
        //✅ 이미지
        var imageFileNames : [String] = []
        //파일 매니저에 이미지 저장
        for (offset, image) in selectedImages.enumerated() {
            print("🥰 이미지 이름 -> ", "\(storeInfo.id)_\(currentDate)_\(offset)")
            
            //realm 에 저장할 파일 이름 만들기
            let dateString = DateFormatManager.shared.getDateFormatter(format: .yearMonthDay).string(from: currentDate)
            let fileName = "\(storeInfo.id)_\(dateString)_\(offset)"
            imageFileNames.append(fileName)
            
            //파일매니저에 이미지 하나씩 저장
            ImageSavingManager.saveImageToDocument(image: image, filename: fileName)
        }
        //array 형태의 이미지 파일 이름 리스트 -> RealmSwift.List 형태
        let realmListPhotoNames : RealmSwift.List<String> = RealmSwift.List()
        realmListPhotoNames.append(objectsIn: imageFileNames)
        
        print("🥰🥰imageFileNames -> ", imageFileNames)
        
        //✅ 리뷰 컨텐츠
        let reviewContent = ReviewContent(photoFileNames:realmListPhotoNames, storeReviewText: storeReviewText, productReviewText: productReviewText,reviewTags:realmListTagIDs , starRate: starRate)
        
        myStoreRepository.addReview(storeID: storeInfo.id, reviewContent: reviewContent, storeInfo: storeInfo)
        
        output.saveReviewComplete = true
    }
}


// MARK: - Input & Output
extension ReviewWriteViewModel {
    
    struct Input {
        let saveReview = PassthroughSubject<LocationDocument, Never>()
        let getReviewForID = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        var errorOccur : RepositoryError?
        var saveReviewComplete : Bool = false
    }
}


// MARK: - Action
extension ReviewWriteViewModel{
    enum Action {
        case saveReview(storeInfo : LocationDocument)
        case getReview(storeID : String)
    }
    
    func action (_ action:Action) {
        switch action {
        case .saveReview(let storeInfo):
            input.saveReview.send(storeInfo)
        case .getReview(let storeID):
            input.getReviewForID.send(storeID)
        }
    }
}

