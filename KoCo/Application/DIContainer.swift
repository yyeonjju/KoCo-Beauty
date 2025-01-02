//
//  DIContainer.swift
//  KoCo
//
//  Created by 하연주 on 12/15/24.
//

import Foundation

//의존성 주입을 중앙화/팩토리 패턴
enum DIContainer {
    
    // MARK: - ViewModel
    static func makeMapViewModel() -> MapViewModel {
        return MapViewModel(
            defaultMyStoreRepository: makeMyStoreRepository(),
            defaultLocationImageRepository: makeLocationImageRepository(),
            defaultLocationDataRepository: makeLocationDataRepository()
        )
    }
    
    static func makeReviewWriteViewModel() -> ReviewWriteViewModel {
        return ReviewWriteViewModel(
            defaultMyStoreRepository: makeMyStoreRepository()
        )
    }
    
    // MARK: - Repository
    private static func makeMyStoreRepository() -> MyStoreRepository {
        return DefaultMyStoreRepository(myStoreRealmManger: makeMyStoreRepository())
    }
    private static func makeLocationImageRepository() -> LocationImageRepository {
        return DefaultLocationImageRepository()
    }
    private static func makeLocationDataRepository() -> LocationDataRepository {
        return DefaultLocationDataRepository()
    }
    
    // MARK: - DataSource
    private static func makeMyStoreRepository() -> any RealmManagerType & MyStoreRealmMangerType {
        return MyStoreRealmManager()
    }

}
