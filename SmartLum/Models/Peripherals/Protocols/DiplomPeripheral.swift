//
//  DiplomPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DiplomPeripheral {
    
}

extension DiplomPeripheral where Self:BasePeripheralProtocol {
    func readValue(from characteristic: CBCharacteristic) {
        print("Diplom extension read - \(characteristic.value)")
    }
}
