//
//  AdvertisedData.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Результат сканироваия Bluetooth (по сути найденное устройство).
class AdvertisedData: NSObject {
    
    let centralManager: CBCentralManager
    let peripheral: CBPeripheral
    let advertisingData: [String : Any]
    public private(set) var advertisedName: String = "peripheral_name_unknown".localized
    public private(set) var RSSI          : NSNumber
    public var peripheralType : PeripheralProfile?
    
    init(withPeripheral peripheral: CBPeripheral,
         advertisementData advertisementDictionary: [String : Any],
         andRSSI currentRSSI: NSNumber,
         using manager: CBCentralManager) {
        self.centralManager = manager
        self.peripheral = peripheral
        self.advertisingData = advertisementDictionary
        self.RSSI = currentRSSI
        super.init()
        self.advertisedName = getAdvertisedName(advertisementDictionary)
        self.peripheralType = getAdvertisedService(advertisementDictionary)
        
    }
    
    private func getAdvertisedName(_ advertisementDictionary: [String : Any]) -> String {
        var advertisedName: String
        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "peripheral_name_unknown".localized
        }
        return advertisedName
    }
    
    private func getAdvertisedService(_ advertisementDictionary: [String : Any]) -> PeripheralProfile? {
        if let advUUID = advertisementDictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            for uuid in advUUID {
                if (UUIDs.advServices.keys.contains(uuid)) {
                    return PeripheralProfile.getPeripheralProfile(uuid: uuid)
                }
            }
        }
        return nil
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if object is AdvertisedData {
            let peripheralObject = object as! AdvertisedData
            return peripheralObject.peripheral.identifier == peripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == peripheral.identifier
        } else {
            return false
        }
    }
}
