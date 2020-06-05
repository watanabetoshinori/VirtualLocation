//
//  BLEClient.swift
//  VirtualLocation
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import CoreBluetooth

/// BLEクライアント
class BLEClient: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    /// 現在の位置情報
    var location: Location!

    /// ローカルネーム
    private let kLocalName = "VirtualLocation"

    /// セントラルマネージャー
    private var centralManager: CBCentralManager!

    /// ペリフェラル
    private var peripheral: CBPeripheral!

    /// BLE経由で受信したモデル
    @Published var model: IndoorBike?

    // MARK: - シングルトンの初期化

    static let shared = BLEClient()

    override private init() {

    }

    func initialize(with location: Location) {
        self.location = location
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }

    // MARK: - CBCentralManager デリゲート

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }

        // BLEに接続したらペリフェラルのスキャンを開始
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            localName == kLocalName else {
            return
        }

        // ペリフェラルを見つけたらインスタンスを保持
        self.peripheral = peripheral

        // ペリフェラルに接続
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // ペリフェラルに接続したらサービスを検索
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil

        // ペリフェラルから切断した場合は、再度ペリフェラルのスキャンを開始
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    // MARK: - CBPeripheral デリゲート

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print(error)
            return
        }

        // サービスに接続したらキャラクタリスティックを検索
        peripheral.services?.forEach { (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print(error)
            return
        }

        // キャラクタリスティックを発見したら通知の受信を設定
        service.characteristics?.forEach({ (characteristic) in
            peripheral.setNotifyValue(true, for: characteristic)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
            return
        }

        guard let value = characteristic.value else {
            return
        }

        do {
            // 通知を受信したらJSONとしてパース
            let model = try JSONDecoder().decode(IndoorBike.self, from: value)

            if let _ = model.delta {
                // 移動
                NotificationCenter.default.post(name: .MoveCurrentLocation, object: nil)
            }

            if let heading = model.heading {
                // 方向
                location.heading = (360 / 16) * Double(heading)
            }

        } catch {
            print(error)
        }
    }

}
