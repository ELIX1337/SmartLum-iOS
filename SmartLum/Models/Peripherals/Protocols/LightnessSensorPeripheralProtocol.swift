//
//  LightnessSensorPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 08.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol LightnessSensorPeripheralProtocol {
    func writeTopSensorLightness(_ lightness: Int)
    func writeBotSensorLightness(_ lightness: Int)
}

extension LightnessSensorPeripheralProtocol where Self:BasePeripheralProtocol {
    var topSensorTriggerLightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.topSensorTriggerLightness]] } }
    var botSensorTriggerLightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.botSensorTriggerLightness]] } }
    
    func writeTopSensorLightness(_ lightness: Int) {
        writeWithoutResponse(value: lightness.toDynamicSizeData(), to: topSensorTriggerLightnessCharacteristic)
    }
    func writeBotSensorLightness(_ lightness: Int) {
        writeWithoutResponse(value: lightness.toDynamicSizeData(), to: botSensorTriggerLightnessCharacteristic)
    }

}

protocol LightnessSensorPeripheralDelegate {
    func getTopSensorTriggerLightness(lightness: Int)
    func getBotSensorTriggerLightness(lightness: Int)
    func getTopSensorCurrentLightness(lightness: Int)
    func getBotSensorCurrentLightness(lightness: Int)
}
