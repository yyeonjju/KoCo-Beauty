//
//  ReviewWriteView.swift
//  KoCo
//
//  Created by 하연주 on 10/6/24.
//

import SwiftUI
import PhotosUI

struct ReviewSectionType {
    var isContentShown : Bool
    let title : String
    
}
enum ReviewSection : String, CaseIterable {
    case addPhotos = "영수증/사진 기록"
    case addStoreReview = "매장 방문 후기"
    case addProductReview = "화장품/제품 사용 후기"
    case addTags = "태그"
    case addStarRate = "별점"
}

struct ReviewWriteView: View {
    @StateObject private var vm = ReviewWriteViewModel(myStoreRepository: MyStoreRepository())
    
    @Binding var isPresented : Bool
    var operation : Operation = .create
    var storeInfo : LocationDocument
    
    
    //TODO: 🌸 여기 전 페이지에서 넘겨줄 때  operation & isFlaged 파악해서 넘겨주기 🌸
    //TODO: 🌸 키보드 내리기
    
    
    @State private var sections : [ReviewSectionType] = []
    
    //태그
    private let tags : [String] = ReviewTag.allCases.map{$0.rawValue}
    //    [
    //
    //        "가격이 합리적임",
    //        "비싼 만큼 가치 있음",
    //
    //        "매장이 청결함",
    //        "매장이 청결하지 않음",
    //
    //        "매장이 트렌디함",
    //
    //        "제품 퀄리티 좋음",
    //
    //        "직원이 친절함",
    //        "직원이 불친절함",
    //
    //        "주차가 편리함",
    //        "대기 공간이 편안함",
    //        "예약이 편리함",
    //        "추천",
    //        "비추천"
    //    ]
    
    //    [
    //        "가격이 합리적임", "비싼 만큼 가치 있음", "매장이 청결함", "매장이 트렌디함", "제품 퀄리티 좋음", "직원이 친절함", "주차가 편리함", "대기 공간이 편안함", "예약이 편리함", "추천", "비추천"
    //    ]
    
    //    [
    //        "합리적인 가격", "비싼 만큼 가치 있음", "청결", "제품 퀄리티 좋음", "친절", "트렌디함", "주차 편리", "편안한 대기 공간", "추천", "비추천", "편리한 예약"
    //    ]
    
    
    
    var body: some View {
        if sections.isEmpty {
            ProgressView()
                .onAppear{
                    self.sections = ReviewSection.allCases.map{
                        ReviewSectionType(isContentShown: self.operation == .create ? false : true, title: $0.rawValue)
                    }
                }
            
        } else {
            ScrollView(showsIndicators : false){
                
                headerView
                    .padding(.vertical)
                
                
                ReviewSectionView(isContentShown: $sections[0].isContentShown, title: sections[0].title){
                    addPhotosView
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[1].isContentShown, title: sections[1].title){
                    addStoreReviewView
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[2].isContentShown, title: sections[2].title){
                    addProductReviewView
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[3].isContentShown, title: sections[3].title){
                    addTagsView
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[4].isContentShown, title: sections[4].title){
                    addStarRateView
                }
                .padding(.bottom,5)
                
                Button{
                    print("리뷰 등록버튼 눌림", vm.starRate)
                    
                    vm.action(.saveReview(storeInfo: storeInfo))
                } label : {
                    Text("리뷰 등록")
                        .frame(maxWidth : .infinity)
                        .asNormalOutlineText(isFilled : true, height : 50)
                }
                .padding(.top, 20)
                
            }
            .padding(.horizontal)
            .frame(maxWidth : .infinity, maxHeight: .infinity)
            .background(Assets.Colors.gray5)
            
        }
        
    }
}




extension ReviewWriteView {
    var headerView : some View {
        HStack(alignment : .top) {
            VStack(alignment : .leading){
                Text(storeInfo.placeName)
                    .foregroundStyle(.skyblue)
                Text("리뷰를 등록해주세요!")
            }
            .asTitleText()
            
            Button {
                isPresented = false
            } label : {
                Assets.SystemImage.xmark
                    .foregroundColor(.gray)
            }
            
        }
    }
    
    var addPhotosView : some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                ForEach(vm.selectedImages, id : \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .background(Assets.Colors.gray4)
                        .frame(width : 80, height : 80)
                        .cornerRadius(10)
                        .scaledToFill()
                }
                
                PhotosPicker(
                    selection: Binding(
                        get: {vm.selectedPhotos },
                        set: {vm.selectedPhotos = $0}
                    ),
                    matching: .images
                ) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width : 80, height : 80)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(10))
                                .stroke(Assets.Colors.skyblue, lineWidth: 2)
                        )
                        .overlay{
                            Assets.SystemImage.plusCircleFill
                                .foregroundStyle(Assets.Colors.skyblue)
                                .imageScale(.large)
                        }
                }
                Spacer()
            }
        }
        .padding([.leading,.bottom])
        .onChange(of: vm.selectedPhotos) { newValue in
            print("💕", Thread.isMainThread)
            convertSelectedPhotosToImages(newValue)
        }
    }
    
    var addStoreReviewView : some View {
        VStack{
            TextField(
                "매장 리뷰",
                text: Binding(
                    get: {vm.storeReviewText },
                    set: {vm.storeReviewText = $0}
                ),
                axis: .vertical
            )
        }
        .asOutlineView()
        .padding([.bottom, .horizontal])
    }
    
    var addProductReviewView : some View {
        VStack{
            TextField(
                "제품 리뷰",
                text: Binding(
                    get: {vm.productReviewText },
                    set: {vm.productReviewText = $0}
                ),
                axis: .vertical
            )
        }
        .asOutlineView()
        .padding([.bottom, .horizontal])
    }
    
    var addTagsView : some View {
        VStack{
            HStackMultipleLinesMultipleSelectButtonView(
                elements: tags,
                clickedElements: Binding(
                    get: {vm.clickedTags},
                    set: {vm.clickedTags = $0}
                )
            )
        }
    }
    
    var addStarRateView : some View {
        StarRatingView(
            rating: Binding(
                get: {vm.starRate},
                set: {vm.starRate = $0}
            )
        )
        .padding(.bottom)
    }
    
    
    
    private func convertSelectedPhotosToImages(_ newPhotos: [PhotosPickerItem]) {
        vm.selectedImages.removeAll()
        
        for newPhoto in newPhotos{
            newPhoto.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data, let newImage = UIImage(data: data){
                        DispatchQueue.main.async {
                            vm.selectedImages.append(newImage)
                        }
                    }
                    
                case .failure(let error):
                    print("error -> ", error)
                }
            }
        }
    }
    
    
}

//#Preview {
//    ReviewWriteView(isPresented : true ,storeName: "하하하하", storeId: "1234")
//}
