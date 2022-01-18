//
//  PeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 14.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import CoreBluetooth

// Общий протокол для BLE устройств
protocol PeripheralProtocol {
    var peripheral: CBPeripheral { get set }
    var endpoints: [[BluetoothEndpoint.Service:BluetoothEndpoint.Characteristic] : CBCharacteristic] { get set }
    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic?)
    func writeWithResponse(value: Data, to characteristic: CBCharacteristic?)
    func setFactorySettings()
}

extension PeripheralProtocol {
    
    // Дефолтные характеристики, которые присутсвуют в любом устройстве SmartLum
    /// Примечание: запись данным способом намного медленнее, будет задержка.
    /// Не критично, когда идет запись единожды, но если  записывать в потоке (например со слайдера), то будет очередь на запись
    var factorySettingsCharacteristic: CBCharacteristic? { get { self.endpoints[[.info:.factorySettings]] } }
    var demoModeCharacteristic:        CBCharacteristic? { get { self.endpoints[[.info:.demoMode]] } }
    
    // Записать данные с ответом от устройства (не использовал, ибо не было надобности)
    func writeWithResponse(value: Data, to characteristic: CBCharacteristic?) {
        if let char = characteristic {
            self.peripheral.writeValue(value, for: char, type: .withResponse)
        }
    }
    
    // Записать данные без ответа, стандартный метод записи
    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic?) {
        print("write \(value) - \(String(describing: characteristic?.uuid))")
        if let char = characteristic {
            if char.properties.contains(.writeWithoutResponse) {
                self.peripheral.writeValue(value, for: char, type: .withoutResponse)
                print("Writing (no response) to \(char.uuid.uuidString) - \(value)")
            } else {
                writeWithResponse(value: value, to: characteristic)
                print("Writing (response) to \(char.uuid.uuidString) - \(value)")
            }
        }
    }
    
    // Сбросить устройство до заводских настроек
    func setFactorySettings() {
        writeWithoutResponse(value: true.toData(), to: factorySettingsCharacteristic)
    }
    
    // Включить демонстрационный режим
    func enableDemoMode() {
        writeWithoutResponse(value: true.toData(), to: demoModeCharacteristic)
    }
    
}

// Стандартный делегат на любое устройство
/// Тут общие события присущие всем устройствам SmartLum
protocol BasePeripheralDelegate {
    
    // Вызывается когда установлено соединение
    func peripheralDidConnect()
    
    // Вызывается когда соединение разорвано
    func peripheralDidDisconnect(reason: Error?)
    
    // Вызывается когда считан и инициализирован весь BLE стэк
    func peripheralIsReady()
    
    // Сообщает, настроено ли устройство
    func peripheralInitState(isInitialized: Bool)
    
    // Вызывается когда на устройстве возникла ошибка
    func peripheralError(code: Int)
    
    // Сообщает версию прошивки устройства
    func peripheralFirmwareVersion(_ version: Int)
    
    // Вызывается когда устройство перешло в режим обновления прошивки (пока не реализовано)
    /// Device Firmware Update
    func peripheralOnDFUMode()
    
    // Сообщает, находится ли устройство в демонстрационном режиме (реализовно не на всех устройствах)
    func peripheralDemoMode(state: Bool)
}

extension BasePeripheralDelegate {
    func peripheralDemoMode(state: Bool) { }
}
