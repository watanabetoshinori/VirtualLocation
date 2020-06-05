//
//  ContentView.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

/// メインコンテンツ
struct ContentView: View {

    /// ビューモデル
    @ObservedObject var viewModel: ContentViewModel

    /// ボディ
    var body: some View {
        ZStack {
            MapView(location: viewModel.location)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.showIntroduction {
                IntroductionView(viewModel: .init(viewModel.location))
            }
        }
    }

}

// MARK: - プレビュー

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(Location()))
    }
}
