//
//  IntroductionViewModel.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

/// /// 起動時の接続ダイアログのモデル
class IntroductionViewModel: ObservableObject {

    /// 現在の位置情報
    var location: Location

    /// エラーアラート
    @Published var alert: ErrorAlert?

    /// 初期化
    init(_ location: Location) {
        self.location = location
    }

    /// Start押下時の処理
    func startPressed() {
        // 依存ライブラリ(libimobiledevice)のチェック
        if Process.isExists("idevice_id") == false {
            self.alert = ErrorAlert(title: "Library not found",
                                    message: "The libimobiledevice library not found.\nPlease install the library from github repository.\nhttps://github.com/libimobiledevice/libimobiledevice")
            return
        }

        // 依存ライブラリ(idevicelocation)のチェック
        if Process.isExists("idevicelocation") == false {
            self.alert = ErrorAlert(title: "Library not found",
                                    message: "The idevicelocation library not found.\nPlease install the library from github repository.\n\nhttps://github.com/JonGabilondoAngulo/idevicelocation")
            return
        }

        // 接続されているデバイスを取得
        guard let device = Device.find() else {
            self.alert = ErrorAlert(title: "Device not connected",
                                    message: "No device connected.\nPlease connect the device and trust this mac.")
            return
        }

        location.device = device
    }

}
