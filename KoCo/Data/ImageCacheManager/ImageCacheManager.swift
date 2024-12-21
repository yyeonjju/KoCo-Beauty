//
//  ImageCacheManager.swift
//  KoCo
//
//  Created by 하연주 on 12/17/24.
//

import Foundation
import Combine


enum UserDefaultsKey : String {
    case etagStorage // [String:String]
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


    case noMemoryCache

    case failSynchronizeWithServer
}

extension ImageCacheManager {
    func synchronizeWithServer(urlString: String, etag : String, cachedImageData : Data) -> AnyPublisher<Data?, ImageLoadError> {

        guard let url = URL(string: urlString) else {
            return Future<Data?, ImageLoadError> { promise in
                promise(.failure(.invalidUrlString))
            }
            .eraseToAnyPublisher()
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
            .print("🪼debug1🪼")
            .tryMap { [weak self]result -> Data? in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ImageLoadError.noResponse
                }

                print("🪼statusCode🪼", httpResponse.statusCode)


                switch httpResponse.statusCode {
                case 200: // 저장된 etag랑 값이 다름 -> 응답으로 받은 데이터 가져옴
                    print("🪼200🪼", result.data)

                    guard let newETag = httpResponse.allHeaderFields["Etag"] as? String else {
                        //⭐️ newETag가 없으면 그냥데이터 리턴
                        return result.data

                    }

                    //⭐️ newETag가 있는 이미지이면 메모리에 캐싱
                    let cacheImage = CacheImage(imageData:  result.data, etag: newETag)
                    self?.cache.setObject(cacheImage, forKey: urlString as NSString)

                    let saved = self?.cache.object(forKey: urlString as NSString)

                    return result.data


                case 304: // 저장된 etag랑 같음 -> 저장되어있던 이미지 반환
                    print("🪼304🪼")
                    return cachedImageData

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

//    @UserDefaultsWrapper(key : .etagStorage, defaultValue: [:]) var etagStorage : [String:String]

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
    func getImageData(urlString : String) -> AnyPublisher<Data?, ImageLoadError> {


//        return Future<Data?, ImageLoadError> { promise in
//            promise(.success(nil))
//        }
//        .eraseToAnyPublisher()

        return returnCachedImageData(urlString: urlString)


    }

    //메모리 히트 & 서버와 동기화된 데이터 리턴
    func returnCachedImageData(urlString: String) -> AnyPublisher<Data?, ImageLoadError> {

        return Future<Data?, ImageLoadError> {[weak self] promise in
            guard let self else {return }

            //1) 메모리에 캐시된 이미지가 있는지 검색
//            guard let cachedImage = self.cache.object(forKey: urlString as NSString) else{
//                return promise(.failure(.noMemoryCache))
//            }
//            print("📍📍📍📍📍메모리에 저장된 이미지가 있음", cachedImage.etag)

            ////⭐️해당하는 이미지 없을 때 네트워킹으로 이미지 로드하는거 따로 해야하나? 아니면 etag 그냥 빈 문자로 보내서 받아오까?
            ///일단은 후자로 작업하기
            let cachedImage = self.cache.object(forKey: urlString as NSString)
        print("📍📍📍📍📍", cachedImage?.etag)


            //2) 메모리에 캐시된 이미지가 있다면
            //⭐️-> etag를 가져와서 서버와 싱크 확인
            let cachedEtag = cachedImage?.etag ?? ""
            let cachedImageData = cachedImage?.imageData ?? Data()
//            return synchronizeWithServer(etag: cachedEtag, cachedImageData : cachedImageData)
            synchronizeWithServer(urlString : urlString, etag: cachedEtag, cachedImageData : cachedImageData)
                .sink(receiveCompletion: { completion in
                    print("🪼🪼🪼🪼🪼🪼🪼---completion---", completion)
//                    switch completion {
//                    case .finished:
//                        break
//                    case .failure(let error):
//                        return promise(.failure(ImageLoadError.failSynchronizeWithServer))
//
//                    }
                }, receiveValue: { value in
                    print("🪼🪼🪼🪼🪼🪼🪼---value---", value)
                    return promise(.success(value))
                })
                .store(in: &cancellables)

//            promise(.success((cachedEtag, cachedImageData)))

        }

//        .flatMap{ [weak self] cachedEtag, cachedImageData in
//            guard let self else {return }
//            return self.synchronizeWithServer(etag: cachedEtag, cachedImageData : cachedImageData)
//        }
        .eraseToAnyPublisher()


    }



    //1 메모리 캐시 확인
//    private func returnCachedImageData(forKey key: String, etag : String) -> Data? {
//        // 메모리에서 로드
//        //1) 이미지를 네트워크에서 다운로드하기 전에 캐시된 이미지가 있는지 검색
//        //캐시된 이미지가 있고 etag가 같다면
//        if let cachedImage = cache.object(forKey: key as NSString), etag == cachedImage.etag {
//            //2) 메모리에 캐시된 이미지가 있다면 -> 캐시된 이미지를 가져와서 imag 리턴
//            return cachedImage.imageData
//        }
//
//
//        // 디스크에서 로드
//        //3) 메모리에 캐시된 이미지가 없다면 -> filemanager에 저장된 이미지 있는지 검색
//        let fileName = makeFileNameForSaving(urlString: key)
//        let fileURL = cacheDirectory.appendingPathComponent(fileName)
//
//        //✅✅✅✅ etag도 같은지 검증해야함
//        if let data = try? Data(contentsOf: fileURL), etag == etagStorage[fileName]  {
//            //4) 디스크 캐싱이 되어 있다면 -> 앱이 꺼지기 전까지 메모리에 캐싱해둘 수 있도록
//            // 메모리에 캐싱
//            //✅✅✅✅ 메모리에 etag도 같이 저장
//            cache.setObject(CacheImage(imageData: data, etag: etag), forKey: key as NSString)
//            return data
//        }
//
//        //5) 메모리와 디스크 모두 캐싱되어 있지 않다면 nil 반환
//        return nil
//    }
}
