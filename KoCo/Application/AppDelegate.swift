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
        // version 2 : ReviewContent에 tags 추가
        // version 3 : ReviewContent에 photoFileNames 추가
        // version 4 : ReviewContent에 reviewTags 추가
        // version 5 : ReviewContent에 tags 삭제
        let config = Realm.Configuration(schemaVersion: 5) { migration, oldSchemaVersion in
            if oldSchemaVersion < 5 {
                //단순 컬럼, 테이블 추가나 삭제 등에 대해서는 코드 X
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        SDKInitializer.InitSDK(appKey: APIKey.kakaoNativeAppKey)
        return true
    }
}
