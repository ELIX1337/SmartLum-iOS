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
        if let characteristic = ledStateCharacteristic {
            print("Writing led state \(state)")
            peripheral.writeValue(state.toData(), for: characteristic, type: .withResponse)
        }
    }
    
    func writeLedBrightness(_ brightness: Int) {
        if let characteristic = ledBrightnessCharacteristic {
            let data = withUnsafeBytes(of: brightness) { Data($0) }
            print("Writing led brightness \(data) for \(characteristic.uuid.uuidString)")
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    func writeLedTimeout(_ timeout: Int) {
        if let characteristic = ledTimeoutCharacteristic {
            print("Writing led timeout \(timeout)")
            peripheral.writeValue(timeout.toData(), for: characteristic, type: .withResponse)
        }
    }

}

protocol LedPeripheralDelegate {
    func getLedState(state: Bool)
    func getLedBrightness(brightness: Int)
    func getLedTimeout(timeout: Int)
}

