//
//  CacheAsyncImage.swift
//  KoCo
//
//  Created by 하연주 on 12/21/24.
//

import SwiftUI
import Combine

struct CacheAsyncImage: View {
    var url : String?
    var width : CGFloat = 80
    var height : CGFloat = 80
    var radius : CGFloat = 4
    
    var allowEnlarger : Bool = false
    var allowMagnificationGesture : Bool = false

    @StateObject var vm = CacheAsyncImageViewModel()
    
    var body: some View {
        
        VStack {

            if let imageData = vm.imageData, let uiImage = UIImage(data: imageData) {
                let image = Image(uiImage: uiImage)
                
                image
                    .resizable()
                    .asEnlargeImage(
                        image :image,
                        allowEnlarger : allowEnlarger,
                        allowMagnificationGesture: allowMagnificationGesture
                    )
            }else {
                defaultContent
            }
        }
        .frame(width : width, height : height)
        .background(Color.gray5)
        .cornerRadius(radius)
        .scaledToFit()
        .onChange(of: url) { url in
            guard let url else{return }
            vm.loadImage(url: url)
        }

    }
    
    private var defaultContent : some View {
        Color.gray5
            .overlay {
                Assets.SystemImage.photo
                    .foregroundStyle(.gray3)
            }
    }
    

}


final class CacheAsyncImageViewModel : ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var imageData : Data?
    
    func loadImage (url : String) {
        
        ImageCacheManager.shared.getImageData(urlString: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure:
                    self.imageData = nil
                case .finished:
                    break
                }

            }, receiveValue: { [weak self]value in
                guard let self ,let value else {return }
                self.imageData = value
            })
            .store(in: &cancellables)
        
    }
}
