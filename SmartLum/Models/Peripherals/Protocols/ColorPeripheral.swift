//
//  ColorPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol ColorPeripheral {
    func writePrimaryColor(_ color: UIColor)
    func writeSecondaryColor(_ color: UIColor)
    func writeRandomColor(_ state: Bool)
    
    func readPrimaryColor(_ color: UIColor)
    func readSecondaryColor(_ color: UIColor)
    func readRandomColor(_ color: Bool)
}

extension ColorPeripheral where Self:BasePeripheralProtocol {
    var randomColorCharacteristic   : CBCharacteristic? { get { return self.someDict[[.color:.randomColor]] } }
    var primaryColorCharacteristic  : CBCharacteristic? { get { return self.someDict[[.color:.primaryColor]] }  }
    var secondaryColorCharacteristic: CBCharacteristic? { get { return self.someDict[[.color:.secondaryColor]] } }
    
    var primaryColorValue: Data? { get { return self.incomingData[[.color:.primaryColor]]}}
    var secondaryColorValue: Data? { get { return self.incomingData[[.color:.primaryColor]]}}
    var randomColorValue: Data? { get { return self.incomingData[[.color:.primaryColor]]}}

    func writePrimaryColor(_ color: UIColor) {
        print("char check \(String(describing: primaryColorCharacteristic))")
        if let characteristic = primaryColorCharacteristic {
            peripheral.writeValue(color.toData(), for: characteristic, type: .withoutResponse)
            print("Second")
        }
    }
    
    func writeSecondaryColor(_ color: UIColor) {
        if let characteristic = secondaryColorCharacteristic {
            peripheral.writeValue(color.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    
    func writeRandomColor(_ state: Bool) {
        if let characteristic = randomColorCharacteristic {
            peripheral.writeValue(state.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    
    func readPrimaryColor(_ color: UIColor) {
    }
    func readSecondaryColor(_ color: UIColor) {}
    func readRandomColor(_ color: Bool) {}
    
    func readData(c:CBCharacteristic) {
        print("Dickhead")
    }
    
}

