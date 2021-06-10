//
//  SLPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 04.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol SLPeripheralProtocol {
    func connect()
    func disconnect()
}

class SLPeripheral: NSObject,
                    CBCentralManagerDelegate,
                    CBPeripheralDelegate,
                    SLPeripheralProtocol {
    
    let centralManager: CBCentralManager
    let slPeripheral: CBPeripheral
    let advertisingData: [String : Any]
    public private(set) var advertisedName: String?
    public private(set) var RSSI          : NSNumber
    public var type : SLPeripheral.Type?
    public var services: [CBUUID]?
    
    init(withPeripheral peripheral: CBPeripheral,
         advertisementData advertisementDictionary: [String : Any],
         andRSSI currentRSSI: NSNumber,
         using manager: CBCentralManager) {
        self.centralManager = manager
        self.slPeripheral = peripheral
        self.advertisingData = advertisementDictionary
        self.RSSI = currentRSSI
        super.init()
        self.advertisedName = getAdvertisedName(advertisementDictionary)
        self.type = getAdvertisedService(advertisementDictionary)
        self.slPeripheral.delegate = self
    }
    
    private func getAdvertisedName(_ advertisementDictionary: [String : Any]) -> String? {
        var advertisedName: String
        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "Unknown Device".localized
        }
        return advertisedName
    }
    
    private func getAdvertisedService(_ advertisementDictionary: [String : Any]) -> SLPeripheral.Type? {
        if let advUUID = advertisementDictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            for uuid in advUUID {
                if let service = SLPeripheral.advServices[uuid] {
                    return service
                }
            }
        }
        return nil
    }
    
    // Protocol
    
    func connect() {
        centralManager.delegate = self
        centralManager.connect(slPeripheral, options: nil)
        print("Connecting to peripheral")
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(slPeripheral)
        print("Disconnecting from peripheral")
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(self.advertisedName ?? "Unknown SLPeripheral")")
        slPeripheral.discoverServices(services)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(self.advertisedName ?? "Device") - \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {}
    
    // MARK: - NSObject
    override func isEqual(_ object: Any?) -> Bool {
        if object is SLPeripheral {
            let peripheralObject = object as! SLPeripheral
            return peripheralObject.slPeripheral.identifier == slPeripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == slPeripheral.identifier
        } else {
            return false
        }
    }
    
}

extension SLPeripheral {
    private static let advServices:[CBUUID:SLPeripheral.Type] = [FirstPeripheral.ADVERTISING_UUID:FirstPeripheral.self, SecondPeripheral.ADVERTISING_UUID:SecondPeripheral.self]
}

class FirstPeripheral: SLPeripheral {
    
    public static let ADVERTISING_UUID             = CBUUID.init(string: "BB930001-3CE1-4720-A753-28C0159DC777")
    public static let PERIPHERAL_INFO_SERVICE_UUID = CBUUID.init(string: "BB93FFFF-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_SERVICE_UUID           = CBUUID.init(string: "BB930B00-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_SERVICE_UUID       = CBUUID.init(string: "BB930A00-3CE1-4720-A753-28C0159DC777")
    
    init(superPeripheral: SLPeripheral) {
        super.init(withPeripheral:    superPeripheral.slPeripheral,
                   advertisementData: superPeripheral.advertisingData,
                   andRSSI:           superPeripheral.RSSI,
                   using:             superPeripheral.centralManager)
        super.services = [FirstPeripheral.ANIMATION_SERVICE_UUID,
                          FirstPeripheral.COLOR_SERVICE_UUID]
        print("First peripheral init")
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        super.peripheral(peripheral, didDiscoverServices: error)
        if let services = peripheral.services {
            for service in services {
                print(service.uuid)
            }
        }
    }
    
}

class SecondPeripheral: SLPeripheral {
    
    public static let ADVERTISING_UUID             = CBUUID.init(string: "00001523-1212-EFDE-1523-785FEABCD123")
    public static let PERIPHERAL_INFO_SERVICE_UUID = CBUUID.init(string: "00001526-1212-EFDE-1523-785FEABCD123")
    public static let ENVIRONMENT_SERVICE_UUID     = CBUUID.init(string: "00001527-1212-EFDE-1523-785FEABCD123")
    public static let DISTANCE_SERVICE_UUID        = CBUUID.init(string: "00001528-1212-EFDE-1523-785FEABCD123")
    public static let INDICATION_SERVICE_UUID      = CBUUID.init(string: "00001529-1212-EFDE-1523-785FEABCD123")
        
    init(superPeripheral: SLPeripheral) {
        super.init(withPeripheral:    superPeripheral.slPeripheral,
                   advertisementData: superPeripheral.advertisingData,
                   andRSSI:           superPeripheral.RSSI,
                   using:             superPeripheral.centralManager)
        super.services = [SecondPeripheral.ENVIRONMENT_SERVICE_UUID,
                          SecondPeripheral.DISTANCE_SERVICE_UUID,
                          SecondPeripheral.INDICATION_SERVICE_UUID]
        print("Second peripheral init")
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Did discover secondPeripheral services")
        if let services = peripheral.services {
            for service in services {
                print(service.uuid)
            }
        }
    }
    
}
