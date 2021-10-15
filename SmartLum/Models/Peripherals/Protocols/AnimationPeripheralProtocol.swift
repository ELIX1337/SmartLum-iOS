//
//  AnimationPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol AnimationPeripheralProtocol {
    func writeAnimationMode(_ animation: PeripheralAnimations)
    func writeAnimationOnSpeed(_ speed: Int)
    func writeAnimationOffSpeed(_ speed: Int)
    func writeAnimationDirection(_ direction: PeripheralAnimationDirections)
    func writeAnimationStep(_ step: Int)
}

extension AnimationPeripheralProtocol where Self:BasePeripheralProtocol {
    var animationModeCharacteristic:      CBCharacteristic? { get { self.endpoints[[.animation:.animationMode]] } }
    var animationOnSpeedCharacteristic:   CBCharacteristic? { get { self.endpoints[[.animation:.animationOnSpeed]] } }
    var animationOffSpeedCharacteristic:  CBCharacteristic? { get { self.endpoints[[.animation:.animationOffSpeed]] } }
    var animationDirectionCharacteristic: CBCharacteristic? { get { self.endpoints[[.animation:.animationDirection]] } }
    var animationStepCharacteristic:      CBCharacteristic? { get { self.endpoints[[.animation:.animationStep]]}}
    
    func writeAnimationMode(_ animation: PeripheralAnimations) {
        if let characteristic = animationModeCharacteristic {
            peripheral.writeValue(UInt8(animation.code).toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationOnSpeed(_ speed: Int) {
        if let characteristic = animationOnSpeedCharacteristic {
            if characteristic.properties.contains(.writeWithoutResponse) {
                peripheral.writeValue(UInt8(speed).toData(), for: characteristic, type: .withoutResponse)
            } else {
                peripheral.writeValue(UInt8(speed).toData(), for: characteristic, type: .withResponse)
            }
            print("Writing speed - \(speed) - \(characteristic.uuid.uuidString)")
        }
    }
    func writeAnimationOffSpeed(_ speed: Int) {
        if let characteristic = animationOffSpeedCharacteristic {
            peripheral.writeValue(UInt8(speed).toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationDirection(_ direction: PeripheralAnimationDirections) {
        if let characteristic = animationDirectionCharacteristic {
            peripheral.writeValue(direction.code.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationStep(_ step: Int) {
        if let characteristic = animationStepCharacteristic {
            peripheral.writeValue(UInt8(step).toData(), for: characteristic, type: .withoutResponse)
        }
    }

}

protocol AnimationPeripheralDelegate {
    func getAnimationMode(mode: PeripheralAnimations)
    func getAnimationOnSpeed(speed: Int)
    func getAnimationOffSpeed(speed: Int)
    func getAnimationDirection(direction: PeripheralAnimationDirections)
    func getAnimationStep(step: Int)
}
