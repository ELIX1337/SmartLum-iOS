//
//  SlBasePeripheral.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol SlBasePeripheralDelegate: DistanceSensorPeripheralDelegate, LedPeripheralDelegate, AnimationPeripheralDelegate { }

class SlBasePeripheral: BasePeripheral, DistanceSensorPeripheralProtocol, LedPeripheralProtocol, AnimationPeripheralProtocol {
    
    var delegate: SlBasePeripheralDelegate?

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service: BluetoothEndpoint.Service, error: Error?) {
        super.readData(data: data, from: characteristic, in: service, error: error)
        switch (service, characteristic) {
        case (.sensor,.topSensorTriggerDistance):
            delegate?.getTopSensorTriggerDistance(distance: data.toInt())
            print("READING TOP SENSOR - \(data.toInt())")
            break
        case (.sensor,.botSensorTriggerDistance):
            delegate?.getBotSensorTriggerDistance(distance: data.toInt())
            print("READING BOT SENSOR - \(data.toInt())")
            break
        case (.led, .ledState):
            delegate?.getLedState(state: data.toBool())
            break
        case (.led, .ledBrightness):
            delegate?.getLedBrightness(brightness: data.toInt())
            print("DECIMAL VALUE - \(data.toInt()) for CHARACTERISTIC - \(characteristic.uuidString)")
            break
        case (.led, .ledTimeout):
            delegate?.getLedTimeout(timeout: data.toInt())
            break
        case (.animation, .animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: data.toInt())
            break
        default:
            break
        }
    }
    
}

