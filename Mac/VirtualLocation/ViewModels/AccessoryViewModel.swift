//
//  AccessoryViewModel.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine
import MapKit

/// タイトルアクセサリーのモデル
class AccessoryViewModel: ObservableObject {

    /// 現在の位置情報
    var location: Location

    /// 現在の位置設定の有無
    @Published var isCurrentLocationExists = true

    /// Combineのキャンセル
    private var cancellables = [AnyCancellable]()

    /// 初期化
    init(_ location: Location) {
        self.location = location

        location.$coordinate.sink { value in
            self.isCurrentLocationExists = !value.isInvalid
        }
        .store(in: &cancellables)
    }

    /// リセットボタン押下時の処理
    func resetPressed() {
        location.coordinate = kCLLocationCoordinate2DInvalid
        location.device?.reset()
        location.device = nil
    }

}
