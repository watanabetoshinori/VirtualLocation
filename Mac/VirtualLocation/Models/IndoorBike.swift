//
//  IndoorBike.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

/// エアロバイク側機材との通信モデル
struct IndoorBike: Codable {

    /// 方向 (0から16)
    var heading: Int?

    /// 前回の回転時刻からの差分 (ms)
    var delta: Int?

}
