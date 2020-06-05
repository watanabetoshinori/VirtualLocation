//
//  AppDelegate.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let location = Location()

        // BLEクライアントを開始
        BLEClient.shared.initialize(with: location)

        // タイトルバーアクセサリに表示するSwiftUIのビューを作成
        let accessoryHostingView = NSHostingView(rootView: AccessoryView(viewModel: .init(location)))
        accessoryHostingView.frame.size = accessoryHostingView.fittingSize

        let titlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        titlebarAccessoryViewController.view = accessoryHostingView
        titlebarAccessoryViewController.layoutAttribute = .top

        // ウィンドウコンテンツに表示するSwiftUIのビューを作成
        let contentView = ContentView(viewModel: .init(location))

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 480),
            styleMask: [.titled,
                        .closable,
                        .miniaturizable,
                        .resizable,
                        .fullSizeContentView,
                        .unifiedTitleAndToolbar],
            backing: .buffered, defer: false)
        window.title = "Virtual Cycling"
        window.titleVisibility = .hidden
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.toolbar = NSToolbar()
        window.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - UISceneSession ライフサイクル

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // ウィンドウを閉じたらアプリを終了する
        return true
    }

}
