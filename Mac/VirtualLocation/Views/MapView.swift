//
//  MapView.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import MapKit

/// SwiftUI用のMKMapView
struct MapView: NSViewRepresentable {

    /// 現在の位置情報
    @ObservedObject var location: Location

    var mapView = MKMapView()

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }

    func makeNSView(context: Context) -> MKMapView {
        let nsView = self.mapView
        nsView.delegate = context.coordinator

        // 各種コントロールを表示
        nsView.showsCompass = true
        nsView.showsZoomControls = true

        // 現在位置を指定するための長押しジェスチャーを設置
        let pressGesture = NSPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapViewPressed(_:)))
        pressGesture.minimumPressDuration = 0.5
        pressGesture.numberOfTouchesRequired = 1
        nsView.addGestureRecognizer(pressGesture)

        context.coordinator.initialize()

        return nsView
    }

    func updateNSView(_ nsView: MKMapView, context: Context) {

    }

}

// MARK: - プレビュー

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: Location())
    }
}
