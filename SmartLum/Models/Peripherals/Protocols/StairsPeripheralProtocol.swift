//
//  StairsPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 08.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol StairsPeripheralProtocol {
    func writeStepsCount(_ count: Int)
    func writeStandbyState(_ state: Bool)
    func writeStandbyBrightness(_ brightness: Int)
    func writeStandbyTopCount(_ count: Int)
    func writeStandbyBotCount(_ count: Int)
}

extension StairsPeripheralProtocol where Self:BasePeripheralProtocol {
    var stepsCountCharacteristic:        CBCharacteristic? { get { self.endpoints[[.stairs:.stepsCount]] } }
    var standbyStateCharacteristic:      CBCharacteristic? { get { self.endpoints[[.stairs:.standbyState]] } }
    var standbyBrightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.stairs:.standbyBrightness]] } }
    var standbyTopCountCharacteristic:   CBCharacteristic? { get { self.endpoints[[.stairs:.standbyTopCount]] } }
    var standbyBotCountCharacteristic:   CBCharacteristic? { get { self.endpoints[[.stairs:.standbyBotCount]] } }
    
    func writeStepsCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: stepsCountCharacteristic)
    }
    func writeStandbyState(_ state: Bool) {
        writeWithoutResponse(value: state.toData(), to: standbyStateCharacteristic)
    }
    
    func writeStandbyBrightness(_ brightness: Int) {
        writeWithoutResponse(value: brightness.toDynamicSizeData(), to: standbyBrightnessCharacteristic)
    }
    
    func writeStandbyTopCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: standbyTopCountCharacteristic)
    }
    
    func writeStandbyBotCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: standbyBotCountCharacteristic)
    }

}

protocol StairsPeripheralDelegate {
    func getStepsCount(count: Int)
    func getStandbyState(state: Bool)
    func getStandbyBrightness(brightness: Int)
    func getStandbyTopCount(count: Int)
    func getStandbyBotCount(count: Int)
    func getWorkMode(mode: Int)
}
