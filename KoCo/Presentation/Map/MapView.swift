//
//  MapView.swift
//  KoCo
//
//  Created by 하연주 on 9/24/24.
//

import SwiftUI
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    
    var body: some View {
        Text("\(locationManager.lastKnownLocation)")
    }
}

#Preview {
    MapView()
}

//TODO: 카카오맵에 반영
//locationManager.lastKnownLocation 위치 받은걸로 맵뷰 띄워주기
//근데 위치 바꾼걸 감지하는건 어느 클래스에서 해주징..

