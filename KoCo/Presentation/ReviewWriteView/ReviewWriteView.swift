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
    @StateObject private var vm = DIContainer.makeReviewWriteViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case storeReview
        case productReview
    }
    
    @Binding var isPresented : Bool
    var operation : Operation = .create
    var storeInfo : LocationDocument
    
    
    //TODO: 🌸vm.output.errorOccur에 대한 대응🌸
    
    
    @State private var sections : [ReviewSectionType] = []
    @State private var operationState : Operation = .create
    @State private var toastState : Toast.ToastState = .init(message: "", isShowing: false)
    
    //태그
    private let tags : [LocalizedStringKey] = ReviewTagLoalizedStringKey.tagList

    init(isPresented: Binding<Bool>, operation: Operation, storeInfo: LocationDocument) {
        self._isPresented = isPresented
        self.operation = operation
        self.operationState = operation
        self.storeInfo = storeInfo
    }
    
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
                    //operationState에 따라 섹션 공간 토글 여부
                    self.sections = sectionList.map{
                        ReviewSectionType(isContentShown: self.operationState == .create ? false : true, title: $0)
                    }
                }
            
        } else {
            ScrollView(showsIndicators : false){
                
                headerView
                    .padding(.vertical)
                
                
                ReviewSectionView(isContentShown: $sections[0].isContentShown, title: sections[0].title){
                    addPhotosView
//                        .allowsHitTesting(operationState != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[1].isContentShown, title: sections[1].title){
                    addStoreReviewView
                        .allowsHitTesting(operationState != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[2].isContentShown, title: sections[2].title){
                    addProductReviewView
                        .allowsHitTesting(operationState != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[3].isContentShown, title: sections[3].title){
                    addTagsView
                        .allowsHitTesting(operationState != .read)
                }
                .padding(.bottom,5)
                
                ReviewSectionView(isContentShown: $sections[4].isContentShown, title: sections[4].title){
                    addStarRateView
                        .allowsHitTesting(operationState != .read)
                }
                .padding(.bottom,5)
                
                if operationState != .read{
                    Button{
                        
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
                if operationState == .read {
                    vm.action(.getReview(storeID: storeInfo.id))
                }
            }
            .onChange(of: vm.output.saveReviewComplete) { value in
                if value {
                    isPresented = false
                }
            }
            .onChange(of: vm.output.reviewValidationErrorOccur) { error in
                guard let error else {return}
                toastState = Toast.ToastState(message: error.rawValue, isShowing: true)
                vm.output.reviewValidationErrorOccur = nil
            }
            .onTapGesture {
                focusedField = nil
            }
            .toast(message: toastState.message,position: .top ,isShowing: $toastState.isShowing, duration : Toast.long)
            
        }
        
    }
}




extension ReviewWriteView {
    var headerView : some View {
        HStack(alignment : .top) {
            VStack(alignment : .leading){
                Text(storeInfo.placeName)
                    .foregroundStyle(.skyblue)
                Text(operationState == .read ? "작성한 리뷰입니다!" : "리뷰를 등록해주세요!")
                
                if operationState == .read {
                    editButton
                }

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
    
    var editButton : some View {
        Button {
            withAnimation{
                operationState = .edit
            }
        } label : {
            HStack {
                Assets.SystemImage.pencilLine
                    .imageScale(.small)
                
                Text("수정하기")
                    .font(.system(size: 12))
            }
            
            .foregroundColor(Assets.Colors.gray2)
            .padding(.bottom, 2)
        }
        .padding(.top, 4)
    }
    
    var addPhotosView : some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                ForEach(vm.selectedImages, id : \.self) { uiImage in
                    let image = Image(uiImage: uiImage)
                    image
                        .resizable()
                        .background(Assets.Colors.gray4)
                        .frame(width : 80, height : 80)
                        .cornerRadius(10)
                        .scaledToFill()
                        .asEnlargeImage(
                            image: image,
                            allowEnlarger: true,
                            allowMagnificationGesture: true
                        )

                }
                
                if operationState != .read {
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
            .focused($focusedField, equals: .storeReview)
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
            .focused($focusedField, equals: .productReview)
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
