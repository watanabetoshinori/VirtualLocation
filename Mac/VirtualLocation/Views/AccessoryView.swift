//
//  AccessoryView.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import MapKit

/// タイトルアクセサリー
struct AccessoryView: View {

    /// ビューモデル
    @ObservedObject var viewModel: AccessoryViewModel

    /// リセットボタン
    var resetButton: some View {
        Button(action: viewModel.resetPressed) {
            Text("Reset")
                .frame(width: 60)
        }
        .disabled(!viewModel.isCurrentLocationExists)
    }

    /// ボディ
    var body: some View {
        HStack {
            Spacer()
            resetButton
        }
        .padding(.top, -30)
    }

}

// MARK: - プレビュー

struct AccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryView(viewModel: .init(Location()))
    }
}
