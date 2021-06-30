//
//  AdvertisedData.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

class AdvertisedData: NSObject {
    
    let centralManager: CBCentralManager
    let peripheral: CBPeripheral
    let advertisingData: [String : Any]
    public private(set) var advertisedName: String = "Unknown Device".localized
    public private(set) var RSSI          : NSNumber
    public var type : BasePeripheral.Type?
    
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
        self.type = getAdvertisedService(advertisementDictionary)
    }
    
    private func getAdvertisedName(_ advertisementDictionary: [String : Any]) -> String {
        var advertisedName: String
        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "Unknown Device".localized
        }
        return advertisedName
    }
    
    private func getAdvertisedService(_ advertisementDictionary: [String : Any]) -> BasePeripheral.Type? {
        if let advUUID = advertisementDictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            for uuid in advUUID {
                if let service = UUIDs.advServices[uuid] {
                    return service
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
