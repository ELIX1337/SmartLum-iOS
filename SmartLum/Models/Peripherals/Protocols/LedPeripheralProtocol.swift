//
//  LedPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

/// Протокол периферийного устройства с возможностью управления лентой
protocol LedPeripheralProtocol {
    func writeLedState(_ state: Bool)
    func writeLedBrightness(_ brightness: Int)
    func writeLedTimeout(_ timeout: Int)
    func writeLedType(_ type: PeripheralDataModel)
    func writeLedAdaptiveBrightnessState(_ mode: PeripheralDataModel)
}

extension LedPeripheralProtocol where Self:PeripheralProtocol {
    
    /// Состояние светодиодной ленты (вкл или выкл)
    var ledStateCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledState]] } }
    
    /// Яркость светодиодной ленты
    var ledBrightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledBrightness]] } }
    
    /// Таймаут выключения светодиодной ленты (есть не везде)
    var ledTimeoutCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledTimeout]] } }
    
    /// Тип светодиодной ленты (цветная или одноцветная,есть не везде)
    var ledTypeCharateristic: CBCharacteristic? { get { self.endpoints[[.led:.ledType]] } }
    
    /// Адаптивная яркость (есть не везде)
    var ledAdaptiveBrightnessCharateristic: CBCharacteristic? { get { self.endpoints[[.led:.ledAdaptiveBrightness]] } }
    
    func writeLedState(_ state: Bool) {
        writeWithoutResponse(value: state.toData(), to: ledStateCharacteristic)
    }
    
    func writeLedBrightness(_ brightness: Int) {
        writeWithoutResponse(value: brightness.toDynamicSizeData(), to: ledBrightnessCharacteristic)
    }
    
    func writeLedTimeout(_ timeout: Int) {
        writeWithoutResponse(value: timeout.toDynamicSizeData(), to: ledTimeoutCharacteristic)
    }
    
    func writeLedType(_ type: PeripheralDataModel) {
        writeWithoutResponse(value: type.code.toDynamicSizeData(), to: ledTypeCharateristic)
    }
    
    func writeLedAdaptiveBrightnessState(_ mode: PeripheralDataModel) {
        writeWithoutResponse(value: mode.code.toDynamicSizeData(), to: ledAdaptiveBrightnessCharateristic)
    }

}

// Вызывается при чтении данных с устройства
protocol LedPeripheralDelegate {
    func getLedState(state: Bool)
    func getLedBrightness(brightness: Int)
    func getLedTimeout(timeout: Int)
    func getLedType(type: PeripheralDataModel)
    func getLedAdaptiveBrightnessState(mode: PeripheralDataModel)
}

extension LedPeripheralDelegate {
    func getLedType(type: PeripheralDataModel) { }
    func getLedAdaptiveBrightnessState(mode: PeripheralDataModel) { }
}

