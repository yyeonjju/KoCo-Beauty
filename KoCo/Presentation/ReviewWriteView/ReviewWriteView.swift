//
//  ReviewWriteView.swift
//  KoCo
//
//  Created by 하연주 on 10/6/24.
//

import SwiftUI
import PhotosUI

//저장하기 , X 버튼

//사진 추가?
//영수증 기록

//매장 방문 후기
//화장품 사용 후기

//태그

//별점

struct ReviewSectionType {
    var isContentShown : Bool
    let title : String

}
enum ReviewSection : String, CaseIterable {
    case addPhotos = "영수증/사진 기록"
    case addStoreReview = "매장 방문 후기"
    case addProductReview = "화장품 사용 후기"
    case addTags = "태그"
    case addStarRate = "별점"
}

struct ReviewWriteView: View {
    @Binding var isPresented : Bool
    var operation : Operation = .create
    var storeName : String
    var storeId : String

    @State private var sections = ReviewSection.allCases.map{
        ReviewSectionType(isContentShown: false, title: $0.rawValue)
    }

    @State var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
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
            
        }
        .padding(.horizontal)
        .frame(maxWidth : .infinity, maxHeight: .infinity)
        .background(Assets.Colors.gray5)
        
        
        
    }
}




extension ReviewWriteView {
    var headerView : some View {
        HStack(alignment : .top) {
            VStack(alignment : .leading){
                Text(storeName)
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
                
                ForEach(selectedImages, id : \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .background(Assets.Colors.gray4)
                        .frame(width : 80, height : 80)
                        .cornerRadius(10)
                        .scaledToFill()
                }
                
                PhotosPicker(
                    selection: $selectedPhotos,
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
        .onChange(of: selectedPhotos) { newValue in
            convertSelectedPhotosToImages(newValue)
        }
    }
    
    var addStoreReviewView : some View {
        VStack{
            Text("addStoreReviewView")
        }
    }
    
    var addProductReviewView : some View {
        VStack{
            Text("addProductReviewView")
        }
    }
    
    var addTagsView : some View {
        VStack{
            Text("addTagsView")
        }
    }
    
    var addStarRateView : some View {
        VStack{
            Text("addStarRateView")
        }
    }

    
    
    private func convertSelectedPhotosToImages(_ newPhotos: [PhotosPickerItem]) {
        selectedImages.removeAll()
        
        for newPhoto in newPhotos{
            newPhoto.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data, let newImage = UIImage(data: data){
                        selectedImages.append(newImage)
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
