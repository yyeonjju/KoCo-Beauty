//
//  ImageCacheManager.swift
//  KoCo
//
//  Created by 하연주 on 12/17/24.
//

import Foundation
import Combine

//비효율적? -> etag 확인하기 위한 네트워킹 매번.. , 끝나고 저장하기 매번...



enum UserDefaultsKey : String {
    case etagStorage // [String:String]
}

enum ImageCachPolicy {
//    case both
    case memoryOnly
    case diskOnly
}

@propertyWrapper
struct UserDefaultsWrapper<T : Codable> {
    let key : UserDefaultsKey
    let defaultValue : T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {return defaultValue}
            let decoder = JSONDecoder()
            let decodedObject = try? decoder.decode(T.self, from: data)
            guard let decodedObject else {return defaultValue}
            return decodedObject
        }
        set {
            let encoder = JSONEncoder()
            if let encodedStruct = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encodedStruct, forKey: key.rawValue)
            }
        }

    }
}




final class CacheImage {
    let imageData : Data
    let etag : String
    
    init(imageData: Data, etag: String) {
        self.imageData = imageData
        self.etag = etag
    }
}


enum ImageLoadError : Error{
//    case
    case noRequest

    case invalidUrlString
    case noResponse
    case undefinedStatusCode

    case unknownError




    case failSynchronizeWithServer
    
    
    
    
    case noMemoryCache
    case failCatch
    case undefinedError
    
    case noDiskCache
}

extension ImageCacheManager {
    func synchronizeWithServer(urlString: String, etag : String, cachedImageData : Data) -> AnyPublisher<(Data, String?), ImageLoadError> {

        guard let url = URL(string: urlString) else {
            
            
            return Fail<(Data, String?), ImageLoadError>(error: ImageLoadError.invalidUrlString).eraseToAnyPublisher()
//            return Future<Data?, ImageLoadError> { promise in
//                promise(.failure(.invalidUrlString))
//            }
//            .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(etag, forHTTPHeaderField: "If-None-Match")

        print("🪼allHTTPHeaderFields🪼", request.allHTTPHeaderFields)


//        guard let request = try? ImageRouter.loadImage.asURLRequest() else{
//            return Future<Data?, ImageLoadError> { promise in
//                promise(.failure(.noRequest))
//            }
//            .eraseToAnyPublisher()
//        }

        return URLSession.shared.dataTaskPublisher(for: request)
//            .print("🪼debug1🪼")
            .tryMap { [weak self] result -> (Data, String?) in
                guard let self, let httpResponse = result.response as? HTTPURLResponse else {
                    throw ImageLoadError.noResponse
                }

//                print("🪼statusCode🪼", httpResponse.statusCode)


                switch httpResponse.statusCode {
                case 200: // 저장된 etag랑 값이 다름 -> 응답으로 받은 데이터 가져옴
                    print("🪼200🪼", result.data)
                    guard let newETag = httpResponse.allHeaderFields["Etag"] as? String else {
                        // newETag가 없으면 (이미지데이터, nil)로 리턴
                        return (result.data, nil)
                    }
                    return (result.data, newETag)
                    
                case 304: // 저장된 etag랑 같음 -> 저장되어있던 이미지 반환
                    print("🪼304🪼")
                    return (cachedImageData, etag)

                default:
                    print("🪼else🪼")
                    throw ImageLoadError.undefinedStatusCode
                }

            }
            .mapError { error -> ImageLoadError in
                if let error = error as? ImageLoadError {
                    return error
                } else {
                    return ImageLoadError.unknownError
                }
            }
//            .print("🪼debug2🪼")
            .eraseToAnyPublisher()





    }
}

final class ImageCacheManager {
    static let shared = ImageCacheManager()

    var cancellables = Set<AnyCancellable>()

    @UserDefaultsWrapper(key : .etagStorage, defaultValue: [:]) var etagStorage : [String:String]

    private let fileManager = FileManager.default
    private let cache = NSCache<NSString, CacheImage>()
    private let cacheDirectory: URL

    private init() {
        // 캐시 디렉토리 설정
        let urls = fileManager.urls(for: .cachesDirectory, in: .allDomainsMask)
        cacheDirectory = urls.first!.appendingPathComponent("ImageDiskCache")
        print("cacheDirectory", cacheDirectory)
        // 캐시 디렉토리가 없다면 생성
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }


    private func makeFileNameForSaving(urlString : String) -> String{
        return urlString.replacingOccurrences(of: "/", with: "-")
    }


    //최종적으로 반환할 데이터
    func getImageData(urlString : String, policy : ImageCachPolicy = .diskOnly) -> AnyPublisher<Data?, ImageLoadError> {
        let subject = PassthroughSubject<CacheImage?, ImageLoadError>()
        
        switch policy {
//        case .both:
//            print("both")
        case .memoryOnly:
            print("menoryOnly")
            hitMemoryCache(urlString: urlString)
                .subscribe(subject)
                .store(in: &cancellables)
 
        case .diskOnly:
            print("diskOnly")
            hitDiskCache(urlString: urlString)
                .subscribe(subject)
                .store(in: &cancellables)
        }

        return subject
            .catch { imageLoadError  in
                //메모리&디스크에 캐싱되지 않았다는 에러를 받은 경우 -> 기본값으로 내려보냄
//                    if imageLoadError == .noMemoryCache {
                    return Just(CacheImage(imageData: Data(), etag: "-"))
//                    }
            }
            .flatMap{[weak self] resultImage -> AnyPublisher<(Data,String?), ImageLoadError> in
                guard let self, let resultImage else {
                    return Fail(error: ImageLoadError.undefinedError).eraseToAnyPublisher()
                }
                let cachedEtag = resultImage.etag
                let cachedImageData = resultImage.imageData
                //메모리에 캐싱된게 있으면
                return self.synchronizeWithServer(urlString : urlString, etag: cachedEtag, cachedImageData : cachedImageData)
                    
            }
            .tryMap {[weak self] (imageData, etag) in
                guard let self else {return imageData}
                //캐싱 정책에 따라 이미지 캐싱하는 함수 cacheImage 실행
                self.cacheImage(urlString: urlString, imageData: imageData, etag: etag ?? "no Etag", policy: policy)
                return imageData // 이미지 데이터만 리턴
            }
            .mapError{$0 as! ImageLoadError}
            .eraseToAnyPublisher()

    }
    
    //캐싱 작업
    private func cacheImage(urlString : String, imageData : Data, etag : String, policy : ImageCachPolicy) {
        print()
        switch policy {
        case .memoryOnly:
            saveToMemory(urlString: urlString, imageData: imageData, etag: etag)
        case .diskOnly:
            saveToDisk(urlString: urlString, imageData: imageData, etag: etag)
        }
    }
    
    //메모리 hit
    private func hitMemoryCache(urlString: String) -> AnyPublisher<CacheImage?, ImageLoadError> {
        return Future<CacheImage?, ImageLoadError> {[weak self] promise in
            guard let self else {return }

            //1) 메모리에 캐시된 이미지가 있는지 검색
            if let cachedImage = self.cache.object(forKey: urlString as NSString){
                print("📍📍📍📍📍메모리에 저장된 이미지가 있음", cachedImage.etag)
                return promise(.success(cachedImage))
            }
            return promise(.failure(.noMemoryCache))
        }
        .eraseToAnyPublisher()
    }
    
    //디스크 hit
    private func hitDiskCache(urlString: String) -> AnyPublisher<CacheImage?, ImageLoadError> {
        print("💕💕💕💕💕hitDiskCache💕💕💕💕💕")
        
        return Future<CacheImage?, ImageLoadError> {[weak self] promise in
            guard let self else{return }
            let fileName = self.makeFileNameForSaving(urlString: urlString)
            let fileURL = self.cacheDirectory.appendingPathComponent(fileName)

            print("💕💕💕💕💕hitDiskCache - data💕💕💕💕💕", try? Data(contentsOf: fileURL))
            print("💕💕💕💕💕hitDiskCache - etag💕💕💕💕💕", self.etagStorage[fileName])
            
            if let data = try? Data(contentsOf: fileURL), let etag = self.etagStorage[fileName]  {
                print("📍📍📍📍📍디스크에 저장된 이미지가 있음", etag)
                //디스크 캐싱되어 있는 경우 & userDefault에 etag도 저장되어 있을 경우
                let cachedImage = CacheImage(imageData: data, etag: etag)
                return promise(.success(cachedImage))
            }
            return promise(.failure(.noDiskCache))
        }
        .eraseToAnyPublisher()

    }
    
    //메모리에 캐싱
    private func saveToMemory(urlString : String, imageData : Data, etag : String)  {
        let cacheImage = CacheImage(imageData: imageData, etag: etag)
        self.cache.setObject(cacheImage, forKey: urlString as NSString)
    }
    
    //디스크에 캐싱
    private func saveToDisk(urlString : String, imageData : Data, etag : String) {
        print("💕💕💕💕💕saveToDisk💕💕💕💕💕")
        
        let fileName = self.makeFileNameForSaving(urlString: urlString)
        let fileURL = self.cacheDirectory.appendingPathComponent(makeFileNameForSaving(urlString: urlString))
        
        do {
            try imageData.write(to: fileURL)
            etagStorage[fileName] = etag
            print("디스크에 저장 완료")
        } catch {
            print("file save error", error)
        }
    }

}

