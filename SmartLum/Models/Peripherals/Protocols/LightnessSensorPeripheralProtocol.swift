//
//  LightnessSensorPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 08.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

/// Протокол периферийного устройства с датчиками освещенности
protocol LightnessSensorPeripheralProtocol {
    func writeTopSensorLightness(_ lightness: Int)
    func writeBotSensorLightness(_ lightness: Int)
}

extension LightnessSensorPeripheralProtocol where Self:PeripheralProtocol {
    
    /// Граница освещенности для верхнего датчика (или пары датчиков)
    /// При ее прохождении устройство регулирует яркость ленты
    var topSensorTriggerLightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.topSensorTriggerLightness]] } }
    
    /// Граница освещенности для нижнего датчика (или пары датчиков)
    var botSensorTriggerLightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.botSensorTriggerLightness]] } }
    
    func writeTopSensorLightness(_ lightness: Int) {
        writeWithoutResponse(value: lightness.toDynamicSizeData(), to: topSensorTriggerLightnessCharacteristic)
    }
    func writeBotSensorLightness(_ lightness: Int) {
        writeWithoutResponse(value: lightness.toDynamicSizeData(), to: botSensorTriggerLightnessCharacteristic)
    }

}

// Вызывается при чтении данных с устройства
protocol LightnessSensorPeripheralDelegate {
    func getTopSensorTriggerLightness(lightness: Int)
    func getBotSensorTriggerLightness(lightness: Int)
    func getTopSensorCurrentLightness(lightness: Int)
    func getBotSensorCurrentLightness(lightness: Int)
}
