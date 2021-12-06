//
//  AnimationPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol AnimationPeripheralProtocol {
    func writeAnimationMode(_ animation: PeripheralDataElement)
    func writeAnimationOnSpeed(_ speed: Int)
    func writeAnimationOffSpeed(_ speed: Int)
    func writeAnimationDirection(_ direction: PeripheralDataElement)
    func writeAnimationStep(_ step: Int)
}

extension AnimationPeripheralProtocol where Self:BasePeripheralProtocol {
    var animationModeCharacteristic:      CBCharacteristic? { get { self.endpoints[[.animation:.animationMode]] } }
    var animationOnSpeedCharacteristic:   CBCharacteristic? { get { self.endpoints[[.animation:.animationOnSpeed]] } }
    var animationOffSpeedCharacteristic:  CBCharacteristic? { get { self.endpoints[[.animation:.animationOffSpeed]] } }
    var animationDirectionCharacteristic: CBCharacteristic? { get { self.endpoints[[.animation:.animationDirection]] } }
    var animationStepCharacteristic:      CBCharacteristic? { get { self.endpoints[[.animation:.animationStep]]}}
    
    func writeAnimationMode(_ animation: PeripheralDataElement) {
        writeWithoutResponse(value: animation.code.toDynamicSizeData(), to: animationModeCharacteristic)
    }
    
    func writeAnimationOnSpeed(_ speed: Int) {
        writeWithoutResponse(value: speed.toDynamicSizeData(), to: animationOnSpeedCharacteristic)
    }
    
    func writeAnimationOffSpeed(_ speed: Int) {
        writeWithoutResponse(value: speed.toDynamicSizeData(), to: animationOffSpeedCharacteristic)
    }
    
    func writeAnimationDirection(_ direction: PeripheralDataElement) {
        writeWithoutResponse(value: direction.code.toDynamicSizeData(), to: animationDirectionCharacteristic)
    }
    
    func writeAnimationStep(_ step: Int) {
        writeWithoutResponse(value: step.toDynamicSizeData(), to: animationStepCharacteristic)
    }

}

protocol AnimationPeripheralDelegate {
    func getAnimationMode(mode: PeripheralDataElement)
    func getAnimationOnSpeed(speed: Int)
    func getAnimationOffSpeed(speed: Int)
    func getAnimationDirection(direction: PeripheralDataElement)
    func getAnimationStep(step: Int)
}
