//
//  SLPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 04.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

struct BluetoothEndpoints {
    enum ServiceEndpoint: CaseIterable {
        case colorService
        case animationService
        
        var serviceID: String {
            switch self {
            case .colorService:     return "BB930B00-3CE1-4720-A753-28C0159DC777"
            case .animationService: return "BB930A00-3CE1-4720-A753-28C0159DC777"
            }
        }
    }
    
    enum CharacteristicEndpoint: CaseIterable {
        case primaryColorCharacteristic
        case secondaryColorCharacteristic
        case randomColorCharacteristic
        case animationModeCharacteristic
        case animationOnSpeedCharacteristic
        case animationOffSpeedCharacteristic
        case animationDirectionCharacteristic
        case animationStepCharacteristic
        
        var characteristicID: String {
            switch self {
            case .primaryColorCharacteristic:       return "BB930B01-3CE1-4720-A753-28C0159DC777"
            case .secondaryColorCharacteristic:     return "BB930B02-3CE1-4720-A753-28C0159DC777"
            case .randomColorCharacteristic:        return "BB930B03-3CE1-4720-A753-28C0159DC777"
            case .animationModeCharacteristic:      return "BB930A01-3CE1-4720-A753-28C0159DC777"
            case .animationOnSpeedCharacteristic:   return "BB930A02-3CE1-4720-A753-28C0159DC777"
            case .animationOffSpeedCharacteristic:  return "BB930A03-3CE1-4720-A753-28C0159DC777"
            case .animationDirectionCharacteristic: return "BB930A04-3CE1-4720-A753-28C0159DC777"
            case .animationStepCharacteristic:      return "BB930A05-3CE1-4720-A753-28C0159DC777"
            }
        }
    }
    
    static func find(serviceID: String, characteristicID: String) -> [CharacteristicEndpoint] {
    }
}

enum BluetoothEendpoint: CaseIterable {
    
    case color1
    case color2
    
    case mode1
    case mode2
    
    var serviceID: String {
        switch self {
        case .color1: return "A018"
        case .color2: return "A018"
        case .mode1: return "A018"
        case .mode2: return "A017"
        }
    }
    
    var characteristicID: String {
        switch self {
        case .color1: return "A"
        case .color2: return "B"
        case .mode1: return "C"
        case .mode2: return "B"
        }
    }
    
    static func find(serviceID: String, characteristicID: String) -> [BluetoothEendpoint] {
        self.allCases.filter { $0.serviceID == serviceID && $0.characteristicID == characteristicID }
    }
    
}

var characteristics: [BluetoothEendpoint: CBCharacteristic] = [:]

func extractCharacteristics(peripheral: CBPeripheral) {
    peripheral.services?.forEach { service in
        service.characteristics?.forEach { characteristic in
            BluetoothEendpoint.find(serviceID: service.uuid.uuidString, characteristicID: characteristic.uuid.uuidString).forEach { endpoint in
                characteristics[endpoint] = characteristic
            }
        }
    }
}
        
protocol BasePeripheralProtocol {
    var peripheral: CBPeripheral { get }
    var servicesDictionary: [CBUUID : CBService] { get set }
    var characteristicsDictionary: [CBUUID : CBCharacteristic] { get set }
}

protocol ColorPeripheral {
    func writePrimaryColor(_ color: UIColor)
    func writeSecondaryColor(_ color: UIColor)
    func writeRandomColor(_ state: Bool)
}

extension ColorPeripheral where Self:BasePeripheralProtocol {
    var primaryColorCharacteristic: CBCharacteristic? { get { return characteristicsDictionary[UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID] }  }
    var secondaryColorCharacteristic: CBCharacteristic? { get { return self.characteristicsDictionary[UUIDs.COLOR_SECONDARY_CHARACTERISTIC_UUID] } }
    var randomColorCharacteristic   : CBCharacteristic? { get { return self.characteristicsDictionary[UUIDs.COLOR_RANDOM_CHARACTERISTIC_UUID] } }

    func writePrimaryColor(_ color: UIColor) {
        if let characteristic = primaryColorCharacteristic {
            peripheral.writeValue(color.toData(), for: characteristic, type: .withoutResponse)
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
}

protocol AnimationPeripheral {
    func writeAnimationMode(_ animation: Int)
    func writeAnimationOnSpeed(_ speed: Int)
    func writeAnimationOffSpeed(_ speed: Int)
    func writeAnimationDirection(_ direction: Int)
}

extension AnimationPeripheral where Self:BasePeripheralProtocol {
    var animationModeCharacteristic: CBCharacteristic? { get { self.characteristicsDictionary[UUIDs.ANIMATION_MODE_CHARACTERISTIC_UUID] } }
    var animationOnSpeedCharacteristic: CBCharacteristic? { get { self.characteristicsDictionary[UUIDs.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID] } }
    var animationOffSpeedCharacteristic: CBCharacteristic? { get { self.characteristicsDictionary[UUIDs.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID] } }
    var animationDirectionCharacteristic: CBCharacteristic? { get { self.characteristicsDictionary[UUIDs.ANIMATION_DIRECTION_CHARACTERISTIC_UUID] } }
    
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

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    let centralManager: CBCentralManager
    let peripheral: CBPeripheral
    var type : BasePeripheral.Type?
    var name: String
    var servicesDictionary: [CBUUID : CBService] = Dictionary()
    var characteristicsDictionary: [CBUUID : CBCharacteristic] = Dictionary()
    
    init(_ peripheral: CBPeripheral,_ manager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = manager
        self.name = peripheral.name ?? "Unknown Device".localized
        super.init()
        self.peripheral.delegate = self
    }
    
    func connect() {
        centralManager.delegate = self
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(name)")
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(name)")
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(name)")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(name) - \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                self.servicesDictionary[service.uuid] = service
                peripheral.discoverCharacteristics(nil, for: service)
                print("Service found - \(service.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                self.characteristicsDictionary[characteristic.uuid] = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }
        
    // MARK: - NSObject
    override func isEqual(_ object: Any?) -> Bool {
        if object is BasePeripheral {
            let peripheralObject = object as! BasePeripheral
            return peripheralObject.peripheral.identifier == peripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == peripheral.identifier
        } else {
            return false
        }
    }
    
}

class FirstPeripheral: BasePeripheral, ColorPeripheral, AnimationPeripheral {

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        writePrimaryColor(color)
    }
    
    public func setAnimationMode(_ mode: Int) {
        writeAnimationMode(mode)
    }
    
    public func setAnimationOnSpeed(_ speed: Int) {
        writeAnimationOnSpeed(speed)
    }
    
}

class SecondPeripheral: BasePeripheral, ColorPeripheral {
        
    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        writePrimaryColor(color)
    }
    
    public func setSecondaryColor(_ color: UIColor) {
        writeSecondaryColor(color)
    }
    
    public func setRandomColor(_ isEnabled: Bool) {
        writeRandomColor(isEnabled)
    }
    
}

class AdvData: NSObject {
    
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
        if object is AdvData {
            let peripheralObject = object as! AdvData
            return peripheralObject.peripheral.identifier == peripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == peripheral.identifier
        } else {
            return false
        }
    }
}
