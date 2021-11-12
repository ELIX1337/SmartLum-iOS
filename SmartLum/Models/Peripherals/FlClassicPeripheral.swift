//
//  FlClassicPeripheral.swift
//  SmartLum
//
//  Created by Tim on 05.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol FlClassicPeripheralDelegate: ColorPeripheralDelegate, AnimationPeripheralDelegate { }

class FlClassicPeripheral: BasePeripheral, ColorPeripheralProtocol, AnimationPeripheralProtocol {
    
    var delegate: FlClassicPeripheralDelegate?

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service: BluetoothEndpoint.Service, error: Error?) {
        super.readData(data: data, from: characteristic, in: service, error: error)
        switch (service, characteristic) {
        case (.color,.primaryColor):
            delegate?.getPrimaryColor(data.toUIColor())
            break
        case (.color,.secondaryColor):
            delegate?.getSecondaryColor(data.toUIColor())
            break
        case (.color,.randomColor):
            delegate?.getRandomColor(data.toBool())
            break
        case (.animation,.animationMode):
            delegate?.getAnimationMode(mode: PeripheralAnimations(rawValue: data.toInt()) ?? .static)
            break
        case (.animation,.animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: data.toInt())
            break
        case (.animation,.animationDirection):
            delegate?.getAnimationDirection(direction: PeripheralAnimationDirections.init(rawValue: data.toInt()) ?? .fromTop)
            break
        case (.animation,.animationStep):
            delegate?.getAnimationStep(step: Int(data.toUInt8()))
            break
        default:
            break
        }
    }
    
}
