//
//  TorcherePeripheral.swift
//  SmartLum
//
//  Created by Tim on 05.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol TorchereDelegate {
    func peripheralDidConnect()
    func peripheralDidDisconnect()
    func peripheralIsReady()
    func peripheralFirmwareVersion(_ version: Int)
    func peripheralOnDFUMode()
    
    func peripheralPrimaryColor(_ color: UIColor)
    func peripheralSecondaryColor(_ color: UIColor)
    func peripheralRandomColor(_ state:  Bool)
    func peripheralAnimation(_ mode: Int)
    func peripheralAnimationOnSpeed(_ speed: Int)
    func peripheralAnimationOffSpeed(_ speed: Int)
    func peripheralAnimationDirection(_ direction: Int)
    func peripheralAnimationStep(_ step: Int)
}

class TorcherePeripheral: NSObject,
                          CBPeripheralDelegate,
                          CBCentralManagerDelegate {
    
    // MARK: - Torchere sevices and characteristics Identifiers
    
    public static let TORCHERE_SERVICE_UUID    = CBUUID.init(string: "BB930001-3CE1-4720-A753-28C0159DC777")
    public static let FL_MINI_SERVICE_UUID     = CBUUID.init(string: "BB930002-3CE1-4720-A753-28C0159DC777")
    public static let DEVICE_INFO_SERVICE_UUID = CBUUID.init(string: "BB93FFFF-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_SERVICE_UUID       = CBUUID.init(string: "BB930B00-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_SERVICE_UUID   = CBUUID.init(string: "BB930A00-3CE1-4720-A753-28C0159DC777")
    
    public static let DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID = CBUUID.init(string: "BB93FFFE-3CE1-4720-A753-28C0159DC777")
    public static let DEVICE_DFU_CHARACTERISTIC_UUID              = CBUUID.init(string: "BB93FFFD-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_PRIMARY_CHARACTERISTIC_UUID           = CBUUID.init(string: "BB930B01-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_SECONDARY_CHARACTERISTIC_UUID         = CBUUID.init(string: "BB930B02-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_RANDOM_CHARACTERISTIC_UUID            = CBUUID.init(string: "BB930B03-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_MODE_CHARACTERISTIC_UUID          = CBUUID.init(string: "BB930A01-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_ON_SPEED_CHARACTERISTIC_UUID      = CBUUID.init(string: "BB930A02-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID     = CBUUID.init(string: "BB930A03-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_DIRECTION_CHARACTERISTIC_UUID     = CBUUID.init(string: "BB930A04-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_STEP_CHARACTERISTIC_UUID          = CBUUID.init(string: "BB930A05-3CE1-4720-A753-28C0159DC777")
    
    // MARK: - Properties
    
    private let centralManager              : CBCentralManager
    private let basePeripheral              : CBPeripheral
    public private(set) var advertisedName  : String?
    public private(set) var RSSI            : NSNumber
    public var isConnected: Bool {
        return basePeripheral.state == .connected
    }
    public var delegate: TorchereDelegate?
    
    // MARK: - Characteristic properties
    
    private var firmwareVersionCharacteristic   : CBCharacteristic?
    private var dfuCharacteristic               : CBCharacteristic?
    private var colorPrimaryCharacteristic      : CBCharacteristic?
    private var colorSecondaryCharacteristic    : CBCharacteristic?
    private var colorRandomCharacteristic       : CBCharacteristic?
    private var animationModeCharacteristic     : CBCharacteristic?
    private var animationOnSpeedCharacteristic  : CBCharacteristic?
    private var animationOffSpeedCharacteristic : CBCharacteristic?
    private var animationDirectionCharacteristic: CBCharacteristic?
    private var animationStepCharacteristic     : CBCharacteristic?
    
    // MARK: - Public API
    
    init(withPeripheral peripheral: CBPeripheral, advertisementData advertisementDictionary: [String : Any], andRSSI currentRSSI: NSNumber, using manager: CBCentralManager) {
        centralManager = manager
        basePeripheral = peripheral
        RSSI = currentRSSI
        super.init()
        advertisedName = parseAdvertisementData(advertisementDictionary)
        basePeripheral.delegate = self
    }
    
    public func connect() {
        centralManager.delegate = self
        centralManager.connect(basePeripheral, options: nil)
        print("Connecting to \(advertisedName ?? "device")...")    }
    
    public func disconnect() {
        centralManager.cancelPeripheralConnection(basePeripheral)
        print("Cancelling connection with \(advertisedName ?? "device")...")
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        if let char = colorPrimaryCharacteristic {
            let packet: [UInt8] = [UInt8(color.rgb()!.red   * 255),
                                   UInt8(color.rgb()!.green * 255),
                                   UInt8(color.rgb()!.blue  * 255)]
            let data = Data(bytes: packet, count: packet.count)
            basePeripheral.writeValue(data, for: char, type: .withoutResponse)
        }
    }
    
    public func setSecondaryColor(_ color: UIColor) {
        if let char = colorSecondaryCharacteristic {
            let packet: [UInt8] = [UInt8(color.rgb()!.red   * 255),
                                   UInt8(color.rgb()!.green * 255),
                                   UInt8(color.rgb()!.blue  * 255)]
            let data = Data(bytes: packet, count: packet.count)
            basePeripheral.writeValue(data, for: char, type: .withoutResponse)
        }
    }
    
    public func setRandomColor(_ isActive: Bool) {
        if let characteristic = colorRandomCharacteristic {
            var value = isActive ? Data([0x1]) : Data([0x0])
            let data = Data(bytes: &value, count: value.count)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func setAnimation(_ mode: Int) {
        if let characteristic = animationModeCharacteristic {
            var value = UInt8(mode)
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func setAnimationOnSpeed(_ speed: Int) {
        if let characteristic = animationOnSpeedCharacteristic {
            var value = UInt8(speed)
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func setAnimationOffSpeed(_ speed: Int) {
        if let characteristic = animationOffSpeedCharacteristic {
            var value = UInt8(speed)
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func setAnimationDirection(_ direction: Int) {
        if let characteristic = animationDirectionCharacteristic {
            var value = UInt8(direction)
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func setAnimationStep(_ step: Int) {
        if let characteristic = animationStepCharacteristic {
            var value = UInt8(step)
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    public func activateDFU() {
        if let characteristic = dfuCharacteristic {
            var value:UInt8 = 0xAC
            let data = Data(bytes: &value, count: 1)
            basePeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    // MARK: - Implementation
    
    private func parseAdvertisementData(_ advertisementDictionary: [String : Any]) -> String? {
        var advertisedName: String

        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "Unknown Device".localized
        }
        
        return advertisedName
    }
    
    private func discoverPrimaryServices() {
        print("Discovering services...")
        basePeripheral.delegate = self
        basePeripheral.discoverServices([
                                        TorcherePeripheral.COLOR_SERVICE_UUID,
                                        TorcherePeripheral.ANIMATION_SERVICE_UUID,
                                        TorcherePeripheral.DEVICE_INFO_SERVICE_UUID])
    }
    
    private func discoverDeviceInfoCharacteristics(_ service: CBService) {
        print("Discovering device info service characteristics...")
        basePeripheral.discoverCharacteristics([TorcherePeripheral.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.DEVICE_DFU_CHARACTERISTIC_UUID],
                                               for: service)
    }
    
    private func discoverColorCharacteristics(_ service: CBService) {
        print("Discovering color service characteristics...")
        basePeripheral.discoverCharacteristics([
                                                TorcherePeripheral.COLOR_PRIMARY_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.COLOR_SECONDARY_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.COLOR_RANDOM_CHARACTERISTIC_UUID],
                                               for: service)
    }
    
    private func discoverAnimationCharacteristics(_ service: CBService) {
        print("Discovering animation service characteristics...")
        basePeripheral.discoverCharacteristics([
                                                TorcherePeripheral.ANIMATION_MODE_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.ANIMATION_DIRECTION_CHARACTERISTIC_UUID,
                                                TorcherePeripheral.ANIMATION_STEP_CHARACTERISTIC_UUID],
                                               for: service)
    }
    
    private func enableNotification(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Enabling notification for \(characteristic.uuid) characteristic...")
            basePeripheral.setNotifyValue(true, for: characteristic)
        } else {
            print("Cannot enable notifications for \(characteristic.uuid) characterisitc (NO NOTIFY PROPERTY)")
        }
    }
    
    private func parceColor(_ array: Data) -> UIColor {
        return UIColor(
            red:   CGFloat(array[0])/255,
            green: CGFloat(array[1])/255,
            blue:  CGFloat(array[2])/255,
            alpha: 1.0)
    }
    
    private func parceBoolean(_ data: Data) -> Bool {
        return data[0] == 0x1
    }
    
    private func parceInt(_ data: Data) -> Int {
        #warning("TODO: Change converter")
        return Int(UInt16([UInt8](data)))
    }
    
    // MARK: - CBCentralManager Delegate
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("gfg")
    }
    
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print("Shit")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("hh")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("hr")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager stated changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connect")
        if peripheral == basePeripheral {
            print("Connected to \(advertisedName ?? "device")")
            delegate?.peripheralDidConnect()
            discoverPrimaryServices()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == basePeripheral {
            print("Disconnected from \(advertisedName ?? "device") [\(error?.localizedDescription ?? "Unknown error")]")
            delegate?.peripheralDidDisconnect()
        }
    }
    
    // MARK: - CBPeripheral Delegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                switch service.uuid {
                case TorcherePeripheral.DEVICE_INFO_SERVICE_UUID:
                    print("Device info service found")
                    discoverDeviceInfoCharacteristics(service)
                    break
                case TorcherePeripheral.COLOR_SERVICE_UUID:
                    print("Color service found")
                    discoverColorCharacteristics(service)
                    break
                case TorcherePeripheral.ANIMATION_SERVICE_UUID:
                    print("Animation service found")
                    discoverAnimationCharacteristics(service)
                    break
                default:
                    print("Unknown service found \(service.uuid)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                basePeripheral.readValue(for: characteristic)
                switch characteristic.uuid {
                case TorcherePeripheral.COLOR_PRIMARY_CHARACTERISTIC_UUID:
                    print("Color primary characteristic found")
                    colorPrimaryCharacteristic = characteristic
                    break
                case TorcherePeripheral.COLOR_SECONDARY_CHARACTERISTIC_UUID:
                    print("Color second characteristic found")
                    colorSecondaryCharacteristic = characteristic
                    break
                case TorcherePeripheral.COLOR_RANDOM_CHARACTERISTIC_UUID:
                    print("Color random characteristic found")
                    colorRandomCharacteristic = characteristic
                    break
                case TorcherePeripheral.ANIMATION_MODE_CHARACTERISTIC_UUID:
                    print("Animation mode characteristic found")
                    animationModeCharacteristic = characteristic
                    break
                case TorcherePeripheral.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID:
                    print("Animation on speed characteristic found")
                    animationOnSpeedCharacteristic = characteristic
                    break
                case TorcherePeripheral.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID:
                    print("Animation off speed characteristic found")
                    animationOffSpeedCharacteristic = characteristic
                    break
                case TorcherePeripheral.ANIMATION_DIRECTION_CHARACTERISTIC_UUID:
                    print("Animation direction characteristic found")
                    animationDirectionCharacteristic = characteristic
                    break
                case TorcherePeripheral.ANIMATION_STEP_CHARACTERISTIC_UUID:
                    print("Animation step characteristic found")
                    animationStepCharacteristic = characteristic
                    break
                case TorcherePeripheral.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID:
                    print("Device firmware version characteristic found")
                    firmwareVersionCharacteristic = characteristic
                    break
                case TorcherePeripheral.DEVICE_DFU_CHARACTERISTIC_UUID:
                    print("DFU characteristic found")
                    dfuCharacteristic = characteristic
                default:
                    print("Unknown characteristic found \(characteristic.uuid)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Error while updating notification state for characteristic \(characteristic.uuid): \(e.localizedDescription)")
        } else {
            switch characteristic {
            case dfuCharacteristic:
                print("Enabled notifications for DFU characteristic")
                break
            default:
                print("Enabled notifications for unknown characteristic: \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Error while updating characteristic value \(characteristic.uuid): \(e.localizedDescription)")
        } else {
            switch characteristic {
            case colorPrimaryCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralPrimaryColor(parceColor(value))
                }
                break
            case colorSecondaryCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralSecondaryColor(parceColor(value))
                }
                break
            case colorRandomCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralRandomColor(parceBoolean(value))
                }
                break
            case animationModeCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralAnimation(parceInt(value))
                }
                break
            case animationOnSpeedCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralAnimationOnSpeed(parceInt(value))
                }
                break
            case animationOffSpeedCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralAnimationOffSpeed(parceInt(value))
                }
                break
            case animationDirectionCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralAnimationDirection(parceInt(value))
                }
                break
            case animationStepCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralAnimationStep(parceInt(value))
                }
                break
            case firmwareVersionCharacteristic:
                if let value = characteristic.value {
                    delegate?.peripheralFirmwareVersion(parceInt(value))
                }
                break
            default:
                print("Unknown characteristic value change \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to \(characteristic.uuid). \(error.localizedDescription)")
        } else {
            switch characteristic {
            case dfuCharacteristic:
                print("\(advertisedName ?? "Device") is on DFU mode")
                delegate?.peripheralOnDFUMode()
            default:
                print("Did write value for unknown characteristic \(characteristic.uuid) \(Date.timeIntervalSinceReferenceDate)")
            }
        }
    }
    
    // MARK: - NSObject protocols
    
    override func isEqual(_ object: Any?) -> Bool {
        if object is TorcherePeripheral {
            let peripheralObject = object as! TorcherePeripheral
            return peripheralObject.basePeripheral.identifier == basePeripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == basePeripheral.identifier
        } else {
            return false
        }
    }
    
}

struct TorchereData {
    static let animationModes     : [Int:String] = [1: "Tetris",
                                                    2: "Wave",
                                                    3: "Transfusion",
                                                    4: "Full Rainbow",
                                                    5: "Rainbow",
                                                    6: "Static"]
    static let animationDirection : [Int:String] = [1: "From bottom",
                                                    2: "From top",
                                                    3: "To center",
                                                    4: "From center"]
}

public extension UnsignedInteger {
    init(_ bytes: [UInt8]) {
        precondition(bytes.count <= MemoryLayout<Self>.size)

        var value: UInt64 = 0

        for byte in bytes {
            value <<= 8
            value |= UInt64(byte)
        }

        self.init(value)
    }
}
