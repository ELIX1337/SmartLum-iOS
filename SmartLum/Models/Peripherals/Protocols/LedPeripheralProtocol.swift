//
//  LedPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol LedPeripheralProtocol {
    func writeLedState(_ state: Bool)
}

extension LedPeripheralProtocol where Self:BasePeripheralProtocol {
    var ledStateCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledState]] } }
    var ledBrightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledBrightness]] } }
    var ledTimeoutCharacteristic: CBCharacteristic? { get { self.endpoints[[.led:.ledTimeout]] } }

    
    func writeLedState(_ state: Bool) {
        writeWithoutResponse(value: state.toData(), to: ledStateCharacteristic)
    }
    
    func writeLedBrightness(_ brightness: Int) {
        writeWithoutResponse(value: brightness.toDynamicSizeData(), to: ledBrightnessCharacteristic)
    }
    
    func writeLedTimeout(_ timeout: Int) {
        writeWithoutResponse(value: timeout.toDynamicSizeData(), to: ledTimeoutCharacteristic)
    }

}

protocol LedPeripheralDelegate {
    func getLedState(state: Bool)
    func getLedBrightness(brightness: Int)
    func getLedTimeout(timeout: Int)
}

