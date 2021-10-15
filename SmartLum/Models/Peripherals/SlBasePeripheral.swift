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
//    override var baseDelegate: BasePeripheralDelegate? {
//        get { return self.delegate }
//        set { self.delegate = newValue as! TorcherePeripheralDelegate?}
//    }
    private var model = PeripheralDataModel()

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service: BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.sensor,.topSensorTriggerDistance):
            // TODO: - Implement toInt() for double byte
            delegate?.getTopSensorTriggerDistance(distance: data.toInt())
            model.topSensorTriggerDistance.value = data.toInt()
            break
        case (.sensor,.botSensorTriggerDistance):
            // TODO: - Implement toInt() for double byte
            delegate?.getBotSensorTriggerDistance(distance: data.toInt())
            model.botSensorTriggerDistance.value = data.toInt()
            break
        case (.led, .ledState):
            delegate?.getLedState(state: data.toBool())
            model.ledState = data.toBool()
            break
        case (.led, .ledBrightness):
            delegate?.getLedBrightness(brightness: data.toInt())
            model.ledBrightness.value = data.toInt()
            print("DECIMAL VALUE - \(data.toInt()) for CHARACTERISTIC - \(characteristic.uuidString)")
            break
        case (.led, .ledTimeout):
            delegate?.getLedTimeout(timeout: data.toInt())
            model.ledTimeout.value = data.toInt()
            break
        case (.animation, .animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: data.toInt())
            //model.animationOnSpeed = data.toInt()
            model.animationOnSpeed.value = data.toInt()
            break
        default:
            break
        }
    }
    
}

