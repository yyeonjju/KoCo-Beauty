//
//  AppDelegate+Register.swift
//  KoCo
//
//  Created by 하연주 on 2/25/25.
//

import Foundation

extension AppDelegate {
    func registerDependencies() {
        let myStoreRealmManager : any RealmManagerType & MyStoreRealmMangerType = MyStoreRealmManager()
        let networkManager : NetworkManagerProtocol = NetworkManager.shared
        
        //defaultMyStoreRepository
        DIContainer.register(
            type: MyStoreRepository.self,
            DefaultMyStoreRepository(myStoreRealmManger: myStoreRealmManager)
        )
        
        //defaultLocationImageRepository
        DIContainer.register(
            type: LocationImageRepository.self,
            DefaultLocationImageRepository(networkManager : networkManager)
        )
        
        //defaultLocationDataRepository
        DIContainer.register(
            type: LocationDataRepository.self,
            DefaultLocationDataRepository(networkManager : networkManager)
        )
        
        
    }
}
