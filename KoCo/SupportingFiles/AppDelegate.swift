//
//  AppDelegate.swift
//  KoCo
//
//  Created by 하연주 on 10/2/24.
//

import Foundation
import KakaoMapsSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SDKInitializer.InitSDK(appKey: APIKey.kakaoNativeAppKey)
        return true
    }
}
