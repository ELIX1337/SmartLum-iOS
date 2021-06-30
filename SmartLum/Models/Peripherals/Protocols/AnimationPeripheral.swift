//
//  AnimationPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol AnimationPeripheral {
    func writeAnimationMode(_ animation: Int)
    func writeAnimationOnSpeed(_ speed: Int)
    func writeAnimationOffSpeed(_ speed: Int)
    func writeAnimationDirection(_ direction: Int)
}

extension AnimationPeripheral where Self:BasePeripheralProtocol {
    var animationModeCharacteristic:      CBCharacteristic? { get { self.someDict[[.animation:.animationMode]] } }
    var animationOnSpeedCharacteristic:   CBCharacteristic? { get { self.someDict[[.animation:.animationOnSpeed]] } }
    var animationOffSpeedCharacteristic:  CBCharacteristic? { get { self.someDict[[.animation:.animationOffSpeed]] } }
    var animationDirectionCharacteristic: CBCharacteristic? { get { self.someDict[[.animation:.animationDirection]] } }
    
    func writeAnimationMode(_ animation: Int) {
        if let characteristic = animationModeCharacteristic {
            peripheral.writeValue(animation.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationOnSpeed(_ speed: Int) {
        if let characteristic = animationOnSpeedCharacteristic {
            peripheral.writeValue(speed.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationOffSpeed(_ speed: Int) {
        if let characteristic = animationOffSpeedCharacteristic {
            peripheral.writeValue(speed.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    func writeAnimationDirection(_ direction: Int) {
        if let characteristic = animationDirectionCharacteristic {
            peripheral.writeValue(direction.toData(), for: characteristic, type: .withoutResponse)
        }
    }
}
