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
        if let characteristic = topSensorTriggerDistanceCharacteristic {
            print("Writing top distance - \(distance)")
            peripheral.writeValue(UInt8(distance).toDoubleData(false), for: characteristic, type: .withoutResponse)
        }
    }
    func writeBotSensorTriggerDistance(_ distance: Int) {
        if let characteristic = botSensorTriggerDistanceCharacteristic {
            print("Writing bot distance - \(distance)")
            peripheral.writeValue(UInt8(distance).toDoubleData(false), for: characteristic, type: .withoutResponse)
        }
    }

}

protocol DistanceSensorPeripheralDelegate {
    func getTopSensorTriggerDistance(distance: Int)
    func getBotSensorTriggerDistance(distance: Int)
}
