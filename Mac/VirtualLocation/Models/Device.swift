//
//  Device.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import CoreLocation

/// 接続している端末
class Device: NSObject {

    /// UDID
    private var UDID = ""

    /// Macに接続している端末を取得
    class func find() -> Device? {
        let output = Process.execute("idevice_id -l")

        if output.isEmpty == false {
            if let udid = output.components(separatedBy: CharacterSet.newlines).first {
                let device = Device(UDID: udid)
                return device
            }
        }

        return nil
    }

    /// 初期化
    convenience init(UDID: String) {
        self.init()
        self.UDID = UDID
    }

    /// 位置情報の変更を開始
    func simulate(location: CLLocationCoordinate2D) {
        let lat = location.latitude
        let lng = location.longitude

        var command = "idevicelocation -u \(UDID)"

        switch (lat, lng) {
        case (..<0, ..<0):
            command += " -- \(lat) -- \(lng)"
        case (..<0, 0...):
            command += " -- \(lat) \(lng)"
        case (0..., ..<0):
            command += " \(lat) -- \(lng)"
        default:
            command += " \(lat) \(lng)"
        }

        let output = Process.execute(command)
        if output.isEmpty == false {
            print(output)
        }
    }

    /// 位置情報の変更をリセット
    func reset() {
        let output = Process.execute("idevicelocation -s -u \(UDID)")
        if output.isEmpty == false {
            print(output)
        }
    }

}
