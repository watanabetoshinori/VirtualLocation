//
//  MapViewCoordinator.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine
import MapKit

public extension NSNotification.Name {

    /// 現在地を移動する通知
    static let MoveCurrentLocation = Notification.Name("MoveCurrentLocation")

}

extension MapView {

    /// MapViewのコーディネーター
    class MapViewCoordinator: NSObject, MKMapViewDelegate  {

        /// 1回転あたりの移動量
        let perDistance = 4.2   // 4.2は自転車の速度(時速15km). 一般的な歩行速度(時速5km)にするには値を1.38に変更する

        /// アノテーションの識別子
        private let kCurrentLocationIdentifier = "CurrentLocationIdentifier"

        /// MapView
        private var parent: MapView

        /// Combineのキャンセル
        private var cancellables = [AnyCancellable]()

        /// 初期化
        init(_ parent: MapView) {
            self.parent = parent
        }

        /// 通知とCombineの初期化
        func initialize() {
            NotificationCenter.default.addObserver(self, selector: #selector(move), name: .MoveCurrentLocation, object: nil)

            parent.location.$coordinate.sink { coordinate in
                if coordinate.isInvalid {
                    self.remove()
                } else {
                    self.animate(to: coordinate)

                    self.center(to: coordinate)

                    self.parent.location.device?.simulate(location: coordinate)
                }
            }
            .store(in: &cancellables)
        }

        /// 現在地のアノテーション
        var locationAnnotaton: MKPointAnnotation? {
            parent.mapView.annotations.first as? MKPointAnnotation
        }

        // MARK: - MapView デリゲート

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kCurrentLocationIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kCurrentLocationIdentifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.canShowCallout = true
            annotationView?.image = NSImage(named: "UserLocation")
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)

            return annotationView
        }

        // MARK: - ジェスチャーアクション

        @objc func mapViewPressed(_ sender: NSPressGestureRecognizer) {
            guard sender.state == .ended else {
                return
            }

            let point = sender.location(in: parent.mapView)
            parent.location.coordinate = parent.mapView.convert(point, toCoordinateFrom: parent.mapView)

            if locationAnnotaton == nil {
                // 現在位置を追加
                add()
                focus()

            } else {
                // 現在位置を変更
                remove()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.add()
                    self.focus()
                }
            }
        }

        // MARK: - 現在位置の管理

        /// 現在位置を追加
        private func add() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = parent.location.coordinate
            annotation.title = "Current Location"
            parent.mapView.addAnnotation(annotation)
        }

        /// 現在位置を移動
        @objc func move() {
            if parent.location.coordinate.isInvalid {
                return
            }

            let correctHeading = parent.mapView.camera.heading + parent.location.heading

            let latitude = parent.location.coordinate.latitude
            let longitude = parent.location.coordinate.longitude

            let earthCircle = 2 * .pi * 6371000.0

            let latDistance = perDistance * cos(correctHeading * .pi / 180)
            let latPerMeter = 360 / earthCircle
            let latDelta = latDistance * latPerMeter
            let newLat = latitude + latDelta

            let lngDistance = perDistance * sin(correctHeading * .pi / 180)
            let earthRadiusAtLng = 6371000.0 * cos(newLat * .pi / 180)
            let earthCircleAtLng = 2 * .pi * earthRadiusAtLng
            let lngPerMeter = 360 / earthCircleAtLng
            let lngDelta = lngDistance * lngPerMeter
            let newLng = longitude + lngDelta

            parent.location.coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
        }

        /// 現在位置にフォーカス
        private func focus() {
            let coordinate = parent.location.coordinate

            if coordinate.isInvalid {
                return
            }

            let currentRegion = parent.mapView.region
            let span = MKCoordinateSpan(latitudeDelta: min(0.002, currentRegion.span.latitudeDelta),
                                        longitudeDelta: min(0.002, currentRegion.span.longitudeDelta))
            let region = MKCoordinateRegion(center: coordinate, span: span)
            parent.mapView.setRegion(region, animated: true)
        }

        /// 現在位置をセンターに
        private func center(to coordinate: CLLocationCoordinate2D) {
            if coordinate.isInvalid {
                return
            }

            parent.mapView.setCenter(coordinate, animated: true)
        }

        /// 指定座標までアニメーションして移動
        private func animate(to coordinate: CLLocationCoordinate2D) {
            if coordinate.isInvalid {
                return
            }

            let duration: Double = 0.5

            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: .linear)
                context.allowsImplicitAnimation = true
                self.locationAnnotaton?.coordinate = coordinate
            }, completionHandler: nil)
        }

        /// 現在位置を削除
        private func remove() {
            guard let annotation = locationAnnotaton else {
                return
            }

            parent.mapView.removeAnnotation(annotation)
        }

    }

}
