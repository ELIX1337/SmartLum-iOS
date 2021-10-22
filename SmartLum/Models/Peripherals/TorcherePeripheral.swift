//
//  TorcherePeripheral.swift
//  SmartLum
//
//  Created by Tim on 05.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol TorcherePeripheralDelegate: ColorPeripheralDelegate, AnimationPeripheralDelegate {
    
}

class TorcherePeripheral: BasePeripheral, ColorPeripheralProtocol, AnimationPeripheralProtocol {
    
    var delegate: TorcherePeripheralDelegate?
    private var model = PeripheralDataModel()

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service: BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.color,.primaryColor):
            delegate?.getPrimaryColor(data.toUIColor())
            model.primaryColor = data.toUIColor()
            break
        case (.color,.secondaryColor):
            delegate?.getSecondaryColor(data.toUIColor())
            model.secondaryColor = data.toUIColor()
            break
        case (.color,.randomColor):
            delegate?.getRandomColor(data.toBool())
            model.randomColor = data.toBool()
            break
        case (.animation,.animationMode):
            delegate?.getAnimationMode(mode: PeripheralAnimations(rawValue: data.toUInt8()) ?? .static)
            model.animationMode = PeripheralAnimations(rawValue: data.toUInt8())
            break
        case (.animation,.animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: Int(data.toUInt8()))
            model.animationOnSpeed.value = Int(data.toUInt8())
            break
        case (.animation,.animationDirection):
            delegate?.getAnimationDirection(direction: PeripheralAnimationDirections.init(rawValue: data.toUInt8()) ?? .fromTop)
            model.animationDirection = PeripheralAnimationDirections(rawValue: data.toUInt8())
            break
        case (.animation,.animationStep):
            delegate?.getAnimationStep(step: Int(data.toUInt8()))
            model.animationStep.value = Int(data.toUInt8())
            break
        default:
            break
        }
    }
    
}
