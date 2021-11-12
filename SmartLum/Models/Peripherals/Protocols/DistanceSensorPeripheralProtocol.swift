//
//  DistanceSensorPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol DistanceSensorPeripheralProtocol {
    func writeTopSensorTriggerDistance(_ distance: Int)
    func writeBotSensorTriggerDistance(_ distance: Int)
}

extension DistanceSensorPeripheralProtocol where Self:BasePeripheralProtocol {
    var topSensorTriggerDistanceCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.topSensorTriggerDistance]] } }
    var botSensorTriggerDistanceCharacteristic: CBCharacteristic? { get { self.endpoints[[.sensor:.botSensorTriggerDistance]] } }
    
    func writeTopSensorTriggerDistance(_ distance: Int) {
        writeWithoutResponse(value: distance.toDynamicSizeData(), to: topSensorTriggerDistanceCharacteristic)
    }
    func writeBotSensorTriggerDistance(_ distance: Int) {
        writeWithoutResponse(value: distance.toDynamicSizeData(), to: botSensorTriggerDistanceCharacteristic)
    }

}

protocol DistanceSensorPeripheralDelegate {
    func getTopSensorTriggerDistance(distance: Int)
    func getBotSensorTriggerDistance(distance: Int)
}
