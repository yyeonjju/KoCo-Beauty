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
    let title : LocalizedStringKey
    
}


struct ReviewWriteView: View {
    @StateObject private var vm = ReviewWriteViewModel(myStoreRepository: MyStoreRepository())
    
    @Binding var isPresented : Bool
    var operation : Operation = .create
    var storeInfo : LocationDocument
    
    
    //TODO: 🌸vm.output.errorOccur에 대한 대응🌸
    //TODO: 🌸 키보드 내리기
    
    
    @State private var sections : [ReviewSectionType] = []
    
    //태그
//    private let tags : [String] = ReviewTag.allCases.map{$0.rawValue}
    private let tags : [LocalizedStringKey] = ReviewTagLoalizedStringKey.tagList
    
    var body: some View {
        
        if sections.isEmpty {
            ProgressView()
                .onAppear{
                    let sectionList = [
                        ReviewSection.addPhotos,
                        ReviewSection.addStoreReview,
                        ReviewSection.addProductReview,
                        ReviewSection.addTags,
                        ReviewSection.addStarRate
                    ]
                    //operation에 따라 섹션 공간 토글 여부
                    self.sections = sectionList.map{
                        ReviewSectionType(isContentShown: self.operation == .create ? false : true, title: $0)
                    }
                }
            
        } else {
            ScrollView(showsIndicators : false){
                
                headerView
                    .padding(.vertical)
                
                
                ReviewSectionView(isContentShown: $sections[0].isContentShown, title: sections[0].title){
                    addPhotosView
                        .allowsHitTesting(operation != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[1].isContentShown, title: sections[1].title){
                    addStoreReviewView
                        .allowsHitTesting(operation != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[2].isContentShown, title: sections[2].title){
                    addProductReviewView
                        .allowsHitTesting(operation != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[3].isContentShown, title: sections[3].title){
                    addTagsView
                        .allowsHitTesting(operation != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[4].isContentShown, title: sections[4].title){
                    addStarRateView
                        .allowsHitTesting(operation != .read)
                }
                .padding(.bottom,5)
                
                if operation == .create {
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
                
            }
            .padding(.horizontal)
            .frame(maxWidth : .infinity, maxHeight: .infinity)
            .background(Assets.Colors.gray5)
            .onAppear{
                if operation == .read {
                    vm.action(.getReview(storeID: storeInfo.id))
                }
            }
            
            
        }
        
    }
}




extension ReviewWriteView {
    var headerView : some View {
        HStack(alignment : .top) {
            VStack(alignment : .leading){
                Text(storeInfo.placeName)
                    .foregroundStyle(.skyblue)
                Text(operation == .create ? "리뷰를 등록해주세요!" : "작성한 리뷰입니다!")
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
                
                if operation == .create {
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
                clickedIndexs: Binding(
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
