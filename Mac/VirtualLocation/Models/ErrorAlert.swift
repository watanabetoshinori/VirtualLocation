//
//  ErrorAlert.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation

/// エラーアラート
struct ErrorAlert: Identifiable {

    /// ID
    var id = UUID().uuidString

    /// タイトル
    var title = ""

    /// メッセージ
    var message = ""

}
