//
//  KoCoApp.swift
//  KoCo
//
//  Created by 하연주 on 9/21/24.
//

import SwiftUI

@main
struct KoCoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            NavigationView {
                MapView()
                    .preferredColorScheme(.light)
                    
            }

        }
    }
}
