//
//  Location.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import MapKit

/// 現在の位置情報
class Location: ObservableObject {

    /// 座標
    @Published var coordinate = kCLLocationCoordinate2DInvalid

    /// 方向
    @Published var heading: Double = 0

    /// 端末
    @Published var device: Device?

}
