/**
 * @file IndoorBike.ino
 * @brief Virtual Location エアロバイク側モジュール
 * @author Watanabe Toshinori
 * @date 2020/05/30
 */

#include <M5Stack.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// オーディオジャックと接続したPIN
const int PIN = 5;

// BLE設定
const char *localName = "VirtualLocation";
const char *serviceUUID = "edeccb55-86b6-4ef2-8711-9cb7c0d3f6a0";
const char *characteristicUUID = "b44924cc-83d8-4376-81f5-6b80e5654768";

// ペダル1回転あたりの距離
const float perDistance = 0.006;
// 最大値
const float maxDistance = 99.99;

// 通知用のBLEキャラクタリスティック
BLECharacteristic *characteristic;

// BLEの端末接続状態
bool isDeviceConnected = false;

// 方向
int heading = 0;

// 距離
float distance = 0.0;

// 現在の表示値
char distanceValue[6];

/**
 * M5Stackのセットアップ
 */
void setup(){
  M5.begin();

  // PINをプルアップに設定
  pinMode(PIN, INPUT_PULLUP);

  // BLEの初期化
  initializeBLE();

  M5.Lcd.setTextColor(WHITE);

  // コンパス
  M5.Lcd.drawLine(280, 80, 280, 100, WHITE);
  M5.Lcd.drawLine(240, 80, 240, 100, WHITE);
  M5.Lcd.drawLine(200, 80, 200, 100, WHITE);
  M5.Lcd.drawLine(160, 80, 160, 100, WHITE);
  M5.Lcd.drawLine(120, 80, 120, 100, WHITE);
  M5.Lcd.drawLine(80, 80, 80, 100, WHITE);
  M5.Lcd.drawLine(40, 80, 40, 100, WHITE);
  M5.Lcd.drawString("N", 150, 50, 4);

  // 中央線
  M5.Lcd.drawLine(0, 100, 320, 100, WHITE);


  // 距離
  M5.Lcd.drawString("00.00", 90, 136, 7);
  M5.Lcd.drawString("km", 236, 165, 4);

  // ボタン
  M5.Lcd.drawString("L", 64, 220, 2);
  M5.Lcd.drawString("R", 252, 220, 2);
}

/**
 * M5Stackのループ
 */
void loop() {
  M5.update();
  
  if (M5.BtnA.wasPressed()) {
    // Aボタンで西側へ向きを変える
    heading -= 1;
    if (heading < 0) {
      heading = 15;
    }
    updateCompass();

    if (isDeviceConnected) {
      notifyHeading();
    }
  }

  if (M5.BtnC.wasPressed()) {
    // Cボタンで東側へ向きを変える
    heading += 1;
    if (heading > 15) {
      heading = 0;
    }
    updateCompass();

    if (isDeviceConnected) {
      notifyHeading();
    }
  }

  int value = digitalRead(PIN);
  if (value == LOW) {
    // エアロバイクを回転すると通電する

    distance = min(distance + perDistance, maxDistance);
    updateDistance();

    if (isDeviceConnected) {
      notifyDistance();
    }

    delay(200);
  }

}

/**
 * BLEのコールバック
 */
class ServerCallbacks: public BLEServerCallbacks {

    void onConnect(BLEServer* pServer) {
      isDeviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
      isDeviceConnected = false;

      // 一定時間待ってからアドバタイジングを再開
      delay(500);
      pServer->startAdvertising();
    }

};

/**
 * BLEを初期化します
 */
void initializeBLE() {
  // デバイスを作成
  BLEDevice::init(localName);

  // サーバーを作成
  BLEServer* server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  // サービスを作成
  BLEService* service = server->createService(serviceUUID);

  // 通知用のキャラクタリスティックを作成
  characteristic = service->createCharacteristic(
                          characteristicUUID,
                          BLECharacteristic::PROPERTY_NOTIFY
                        );
  
  characteristic->addDescriptor(new BLE2902());

  // サービスを開始
  service->start();

  // アドバタイジングを開始
  server->getAdvertising()->start();
}

/**
 * コンパスの表示を更新します
 */
void updateCompass() {

  M5.Lcd.fillRect(0, 0, 320, 80, BLACK);

  switch(heading) {
    case 0:
      M5.Lcd.drawString("N", 150, 50, 4);
      break;
    case 1:
      M5.Lcd.drawString("N", 110, 50, 4);
      M5.Lcd.drawString("E", 270, 50, 4);
      break;
    case 2:
      M5.Lcd.drawString("N", 70, 50, 4);
      M5.Lcd.drawString("E", 230, 50, 4);
      break;
    case 3:
      M5.Lcd.drawString("N", 30, 50, 4);
      M5.Lcd.drawString("E", 190, 50, 4);
      break;
    case 4:
      M5.Lcd.drawString("E", 150, 50, 4);
      break;
    case 5:
      M5.Lcd.drawString("E", 110, 50, 4);
      M5.Lcd.drawString("W", 270, 50, 4);
      break;
    case 6:
      M5.Lcd.drawString("E", 70, 50, 4);
      M5.Lcd.drawString("W", 230, 50, 4);
      break;
    case 7:
      M5.Lcd.drawString("E", 30, 50, 4);
      M5.Lcd.drawString("W", 190, 50, 4);
      break;
    case 8:
      M5.Lcd.drawString("W", 150, 50, 4);
      break;
    case 9:
      M5.Lcd.drawString("W", 110, 50, 4);
      M5.Lcd.drawString("S", 270, 50, 4);
      break;
    case 10:
      M5.Lcd.drawString("W", 70, 50, 4);
      M5.Lcd.drawString("S", 230, 50, 4);
      break;
    case 11:
      M5.Lcd.drawString("W", 30, 50, 4);
      M5.Lcd.drawString("S", 190, 50, 4);
      break;
    case 12:
      M5.Lcd.drawString("S", 150, 50, 4);
      break;
    case 13:
      M5.Lcd.drawString("S", 110, 50, 4);
      M5.Lcd.drawString("N", 270, 50, 4);
      break;
    case 14:
      M5.Lcd.drawString("S", 70, 50, 4);
      M5.Lcd.drawString("N", 230, 50, 4);
      break;
    default:
      M5.Lcd.drawString("S", 30, 50, 4);
      M5.Lcd.drawString("N", 190, 50, 4);
  }
}

/**
 * 距離の表示を更新します
 */
void updateDistance() {
  char buffer[6];
  sprintf(buffer, "%05.2f", distance);

  if (strcmp(distanceValue, buffer) != 0) {
    strncpy(distanceValue, buffer, 6);
    M5.Lcd.fillRoundRect(90, 136, 140, 110, 10, BLACK);
    M5.Lcd.drawString(distanceValue, 90, 136, 7);
  }
}

/**
 * BLEで向きを送信します
 */
void notifyHeading() {
  char json[18];
  sprintf(json, "{\"heading\": %d}", heading);
  characteristic->setValue(json);
  characteristic->notify();

  Serial.println(json);
}

/**
 * BLEで距離を送信します
 */
void notifyDistance() {
  char json[24];
  sprintf(json, "{\"delta\": %lu}", millis());
  characteristic->setValue(json);
  characteristic->notify();

  Serial.println(json);
}
