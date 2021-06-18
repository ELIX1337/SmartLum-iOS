//
//  SLPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 04.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

enum CharacteristicType {
    case firmwareVersion
    case primarycolor
    case secondaryColor
    case randomColor
    case animationMode
    case animationOnSpeed
    case animationOffSpeed
    case animationDirection
}

protocol BasePeripheralProtocol {
    var peripheral: CBPeripheral { get }
    var services: [CBUUID] { get }
    var infoService: CBService? { get }
    var firmwareVersionCharacteristic: CBCharacteristic? { get }
    var dfuCharacteristic:CBCharacteristic? { get }
    func getCharacteristicsUUID(_ type: CharacteristicType) -> CBCharacteristic
}

protocol ColorPeripheral {
    var colorService: CBService? { get }
    var primaryColorCharacteristic  : CBCharacteristic? { get }
    var secondaryColorCharacteristic: CBCharacteristic? { get }
    var randomColorCharacteristic   : CBCharacteristic? { get }
    func writePrimaryColor(_ color: UIColor)
    func writeSecondaryColor(_ color: UIColor)
    func writeRandomColor(_ state: Bool)
}

extension ColorPeripheral where Self:BasePeripheralProtocol {
    var secondaryColorCharacteristic: CBCharacteristic? { get {return nil} set {} }
    var randomColorCharacteristic   : CBCharacteristic? { get {return nil} set {} }
    
    func writePrimaryColor(_ color: UIColor) {
        if let characteristic = secondaryColorCharacteristic {
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
    var animationService: CBService? { get }
    var animationModeCharacteristic: CBCharacteristic? { get }
    var animationOnSpeedCharacteristic: CBCharacteristic? { get }
    var animationOffSpeedCharacteristic: CBCharacteristic? { get }
    var animationDirectionCharacteristic: CBCharacteristic? { get }
    func writeAnimationMode(_ animation: Int)
    func writeAnimationOnSpeed(_ speed: Int)
    func writeAnimationOffSpeed(_ speed: Int)
    func writeAnimationDirection(_ direction: Int)
}

extension AnimationPeripheral where Self:BasePeripheralProtocol {
    
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

protocol DistancePeripheral {
    // No write properties. Only readable
}

protocol IndicationPeripheral {
    // No write properties. Only readable
}

protocol PeripheralDataDelegate {
    func getColor(_ color: Any)
    func getAnimation(_ animation: Any)
    func getAnimationSpeed(_ speed: Any)
    func getDistance(_ distance: Any)
    func getLedState(_ state: Any)
}

class AdvData: NSObject {
    let peripheral: CBPeripheral
    let advertisingData: [String : Any]
    public private(set) var advertisedName: String = "Unknown Device".localized
    public private(set) var RSSI          : NSNumber
    
    init(_ peripheral: CBPeripheral,
         _ advertisementDictionary: [String:Any],
         _ RSSI: NSNumber) {
        self.peripheral = peripheral
        self.advertisingData = advertisementDictionary
        self.RSSI = RSSI
        super.init()
        self.advertisedName = getAdvertisedName(advertisementDictionary)
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

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    let centralManager: CBCentralManager
    let peripheral: CBPeripheral
    let advertisingData: [String : Any]
    public private(set) var advertisedName: String = "Unknown Device".localized
    public private(set) var RSSI          : NSNumber
    public var type : BasePeripheral.Type?
    public var delegate: PeripheralDataDelegate?
    var services: [CBUUID]
    var infoService: CBService?
    var dfuCharacteristic: CBCharacteristic?
    var firmwareVersionCharacteristic: CBCharacteristic?

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
        self.peripheral.delegate = self
    }
    
    convenience init(withServices services: [CBUUID]) {
        self.init(withPeripheral: self.peripheral,
                  advertisementData: self.advertisingData,
                  andRSSI: self.RSSI,
                  using: self.centralManager)
        self.services = services
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
    
    func getCharacteristicsUUID(_ type: CharacteristicType) -> CBCharacteristic {
        return firmwareVersionCharacteristic!
    }
    
    func connect() {
        centralManager.delegate = self
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(advertisedName)")
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(advertisedName)")
    }
    
    func didDiscoverService(_ service:CBService) {}
    
    func discoverCharacteritic(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    func didDiscoverCharacteristic(_ characteristic: CBCharacteristic) {}
    
    func didReceiveData(from characteristic: CBCharacteristic) {}
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(self.advertisedName )")
        peripheral.discoverServices(services)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(self.advertisedName ) - \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                didDiscoverService(service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                didDiscoverCharacteristic(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        didReceiveData(from: characteristic)
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
    
    var colorService: CBService?
    var animationService: CBService?
    var primaryColorCharacteristic: CBCharacteristic?
    var secondaryColorCharacteristic: CBCharacteristic?
    var animationModeCharacteristic: CBCharacteristic?
    var animationOnSpeedCharacteristic: CBCharacteristic?
    var animationOffSpeedCharacteristic: CBCharacteristic?
    var animationDirectionCharacteristic: CBCharacteristic?

    init() {
        super.init(withPeripheral: super.peripheral,
                   advertisementData: super.advertisingData,
                   andRSSI: super.RSSI,
                   using: super.centralManager)
        
        primaryColorCharacteristic = super.getCharacteristicsUUID(.primarycolor)
    }
    
    // ColorPeripheral protocol
    func writePrimaryColor(_ color: UIColor) {
        if let characteristic = primaryColorCharacteristic {
            var value = color
            let data = Data(bytes: &value, count: 1)
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func writeSecondaryColor(_ color: UIColor) {
        if let characteristic = secondaryColorCharacteristic {
            var value = color
            let data = Data(bytes: &value, count: 1)
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    // AnimationPeripheral protocol
    func writeAnimationMode(_ animation: Int) {
        if let characteristic = animationModeCharacteristic {
            var value = UInt8(animation)
            let data = Data(bytes: &value, count: 1)
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func writeAnimationOnSpeed(_ speed: Int) {
        if let characteristic = animationOnSpeedCharacteristic {
            var value = UInt8(speed)
            let data = Data(bytes: &value, count: 1)
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    override func didReceiveData(from characteristic: CBCharacteristic) {
        switch characteristic {
        case primaryColorCharacteristic:
            delegate?.getColor(characteristic.value!)
            break
        case animationModeCharacteristic:
            delegate?.getAnimation(characteristic.value!)
            break
        case animationOnSpeedCharacteristic:
            delegate?.getAnimationSpeed(characteristic.value!)
            break
        default:
            print("Unknown value changed")
        }
    }
    
    override func didDiscoverService(_ service: CBService) {
        switch service.uuid {
        case UUIDs.COLOR_SERVICE_UUID:
            colorService = service
            print("Color service found")
            break
        case UUIDs.ANIMATION_SERVICE_UUID:
            print("Animation service found")
            break
        default:
            print("Unknown service found - \(service.uuid)")
        }
    }
    
    override func didDiscoverCharacteristic(_ characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID:
            primaryColorCharacteristic = characteristic
            break
        case UUIDs.ANIMATION_MODE_CHARACTERISTIC_UUID:
            animationModeCharacteristic = characteristic
            break
        case UUIDs.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID:
            animationOnSpeedCharacteristic = characteristic
            break
        default:
            print("Unknown characteristic found \(characteristic.uuid)")
        }
    }
    
}

class SecondPeripheral: BasePeripheral, ColorPeripheral, DistancePeripheral, IndicationPeripheral {
    
    var colorService: CBService?
    var primaryColorCharacteristic: CBCharacteristic?
    private var distanceCharacteristic   : CBCharacteristic?
    private var indicationCharacteristic : CBCharacteristic?
    
    func discoverColorCharacteristics(in service: CBService) {
        peripheral.discoverCharacteristics([UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID,
                                                UUIDs.COLOR_SECONDARY_CHARACTERISTIC_UUID,
                                                UUIDs.COLOR_RANDOM_CHARACTERISTIC_UUID], for: service)
    }
        
    init() {}
    
    override func didReceiveData(from characteristic: CBCharacteristic) {
        switch characteristic {
        case primaryColorCharacteristic:
            delegate?.getColor(characteristic.value!)
            break
        case distanceCharacteristic:
            delegate?.getDistance(characteristic.value!)
            break
        case indicationCharacteristic:
            delegate?.getLedState(characteristic.value!)
            break
        default:
            print("Unknown value changed")
        }
    }
    
    override func didDiscoverService(_ service: CBService) {
        switch service.uuid {
        case UUIDs.COLOR_SERVICE_UUID:
            discoverCharacteritic([UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID], for: service)
            print("Color service found")
            break
        case UUIDs.DISTANCE_SERVICE_UUID:
            print("Distance service found")
            break
        case UUIDs.INDICATION_SERVICE_UUID:
            print("Indication service found")
        default:
            print("Unknown service found - \(service.uuid)")
        }
    }
    
    override func didDiscoverCharacteristic(_ characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID:
            primaryColorCharacteristic = characteristic
            break
        case UUIDs.DISTANCE_CHARACTERISTIC_UUID:
            distanceCharacteristic = characteristic
            break
        case UUIDs.INDICATION_CHARACTERISTIC_UUID:
            indicationCharacteristic = characteristic
        default:
            print("Unknown characteristic found \(characteristic.uuid)")
        }
    }
    
}
