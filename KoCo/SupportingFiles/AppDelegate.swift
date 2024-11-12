//
//  AppDelegate.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import KakaoMapsSDK
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //바뀔 스키마 버전 넣어주기
        let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                //단순 컬럼, 테이블 추가나 삭제 등에 대해서는 코드 X
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        SDKInitializer.InitSDK(appKey: APIKey.kakaoNativeAppKey)
        return true
    }
}
