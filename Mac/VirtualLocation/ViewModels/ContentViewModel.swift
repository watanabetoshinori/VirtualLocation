//
//  ContentViewModel.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine

/// メインコンテンツのモデル
class ContentViewModel: ObservableObject {

    /// 現在の位置情報
    var location: Location

    /// 現在の位置設定の有無
    @Published var isCurrentLocationExists = true

    /// 接続ダイアログの表示有無
    @Published var showIntroduction = true

    /// Combineのキャンセル
    private var cancellables = [AnyCancellable]()

    /// 初期化
    init(_ location: Location) {
        self.location = location

        location.$coordinate.sink { value in
            self.isCurrentLocationExists = !value.isInvalid
        }
        .store(in: &cancellables)

        location.$device.sink { value in
            self.showIntroduction = (value == nil)
        }
        .store(in: &cancellables)
    }

}
