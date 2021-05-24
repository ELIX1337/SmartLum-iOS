//
//  EasyPeripheral.swift
//  SmartLum
//
//  Created by Tim on 23/11/2020.
//  Copyright © 2020 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol EasyBaseDelegate {
    func peripheralDidConnect(RGBSupported: Bool)
    func peripheralDidDisconnect()
    func peripheralIsReady(isReady: Bool)
    func peripheralConfigured(_ isConfigured: Bool)
    func peripheralSettingsReceived(_ isReceived: Bool)
    func peripheralError(_ register:Int, _ code:Int)
    
    func peripheralLEDColor(_ color: UIColor)
    func peripheralAnimationMode(_ mode: Int)
    func peripheralAnimationOnSpeed(_ speed: Int)
    func peripheralAnimationOffSpeed(_ speed: Int)
    func peripheralRandomColorMode(_ mode: Int)
    func peripheralAdaptiveBrightnessMode(_ state: Bool)
    func peripheralDayNightMode(_ mode: Int)
    func peripheralDayNightModeOnTime(_ time: Int)
    func peripheralDayNightModeOffTime(_ time: Int)
    func peripheralStepsCount(_ count: Int)
}

protocol EasyExtendedDelegate {
    func peripheralStripType(_ type: EasyData.stripType)
    func peripheralBotSensorCurrentDistance(_ distance: Int)
    func peripheralTopSensorCurrentDistance(_ distance: Int)
    func peripheralBotSensorTriggerDistance(_ distance: Int)
    func peripheralTopSensorTriggerDistance(_ distance: Int)
    func peripheralBotSensorDirection(_ direction: Int)
    func peripheralTopSensorDirection(_ direction: Int)
}
 
class EasyPeripheral: NSObject,
                      CBPeripheralDelegate,
                      CBCentralManagerDelegate,
                      SratocolDelegate {
    
    // MARK: - UART services and characterisitcs Identifiers
    
    public static let UART_serviceUUID         = CBUUID.init(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    public static let RX_characteristicUUID    = CBUUID.init(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") // Write here
    public static let TX_characteristicUUID    = CBUUID.init(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") // Notify from
    
    // MARK: - Properties
    
    private let packetManager = Sratocol.shared
    private let centralManager                : CBCentralManager
    private let basePeripheral                : CBPeripheral
    public private(set) var advertisedName    : String?
    public private(set) var RSSI              : NSNumber
    
    public var baseDelegate: EasyBaseDelegate?
    public var extendedDelegate: EasyExtendedDelegate?
    
    // MARK: - Computed variables
        
    public var isConnected: Bool {
        return basePeripheral.state == .connected
    }

    // MARK: - Characteristic properties
    
    private var buttonCharacteristic: CBCharacteristic?
    private var ledCharacteristic   : CBCharacteristic?
    private var rxCharacteristic    : CBCharacteristic?
    private var txCharacteristic    : CBCharacteristic?
    
    // MARK: - Public API
    
    /// Creates the SLPeripheral based on the received peripheral and advertisign data.
    /// The device name is obtaied from the advertising data, not from CBPeripheral object
    /// to avoid caching problems.
    init(withPeripheral peripheral: CBPeripheral, advertisementData advertisementDictionary: [String : Any], andRSSI currentRSSI: NSNumber, using manager: CBCentralManager) {
        centralManager = manager
        basePeripheral = peripheral
        RSSI = currentRSSI
        super.init()
        advertisedName = parseAdvertisementData(advertisementDictionary)
        basePeripheral.delegate = self
    }
    
    /// Connects to the device.
    public func connect() {
        centralManager.delegate = self
        print("Connecting to device...")
        centralManager.connect(basePeripheral, options: nil)
    }
    
    /// Cancels existing or pending connection.
    public func disconnect() {
        print("Cancelling connection...")
        centralManager.cancelPeripheralConnection(basePeripheral)
    }
    
    // MARK: - API
    
    // Requests peripheral current settings
    public func requestPeripheralSettings() {
        writeCharacteristic(packet: packetManager.createSettingsRequestPacket())
    }
    
    public func resetPeripheral() {
        writeCharacteristic(packet: packetManager.createResetPacket())
    }
    
    public func setColor(color: UIColor) {
        writeColor(color: color)
    }
    
    public func setAnimationMode(mode: Int) {
        writeData(Sratocol.Device.Register.ANIMATION, mode)
    }
    
    public func setAnimationOnSpeed(speed: Int) {
        writeData(Sratocol.Device.Register.ANIMATION_ON_SPEED, speed)
    }
    
    public func setAnimationOffSpeed(speed: Int) {
        writeData(Sratocol.Device.Register.ANIMATION_OFF_SPEED, speed)
    }
    
    public func setRandomColorMode(mode: Int) {
        writeData(Sratocol.Device.Register.RANDOM_COLOR_MODE, mode)
    }
    
    public func setAdaptiveBrightnessMode(mode: Bool) {        writeData(Sratocol.Device.Register.ADAPTIVE_BRIGHTNESS_MODE, mode ? 1:0)
    }
    
    public func setDayNightMode(mode: Int) {
        writeData(Sratocol.Device.Register.DAY_NIGHT_MODE, mode)
    }
    
    public func setDayNightModeOnTime(time: Int) {
        writeData(Sratocol.Device.Register.ALARM_A, time)
    }
    
    public func setDayNightModeOffTime(time: Int) {
        writeData(Sratocol.Device.Register.ALARM_B, time)
    }
    
    public func setStripType(type: EasyData.stripType) {
        writeData(Sratocol.Device.Register.STRIP_TYPE, type.rawValue)
    }
    
    public func setTopSensorLocation(location: Int) {
        writeData(Sratocol.Device.Register.TOP_SENS_DIRECTION, location)
    }
    
    public func setBotSensorLocation(location: Int) {
        writeData(Sratocol.Device.Register.BOT_SENS_DIRECTION, location)
    }
    
    public func setTopSensorTriggerDistance(distance: Int) {
        writeData(Sratocol.Device.Register.TOP_SENS_TRIGGER_DISTANCE, distance)
    }
    
    public func setBotSensorTriggerDistance(distance: Int) {
        writeData(Sratocol.Device.Register.BOT_SENS_TRIGGER_DISTANCE, distance)
    }
    
    public func setCustomData(for register: UInt8, with value: Int) {
        writeData(Int(register), value)
    }
    
    // MARK: - Implementation
        
    // Starts UART service discovery
    private func discoverUARTServices() {
        print("Discovering UART service...")
        basePeripheral.delegate = self
        basePeripheral.discoverServices([EasyPeripheral.UART_serviceUUID])
    }

    // Starts characteristic discovery for RX and TX
    private func discoverCharacteristicsForUARTService(_ service: CBService) {
        print("Discovering UART service characteristics...")
        basePeripheral.discoverCharacteristics([EasyPeripheral.RX_characteristicUUID, EasyPeripheral.TX_characteristicUUID], for: service)
    }
    
    /// Enables notification for given characteristic.
    /// If the characteristic does not have notify property, this method will
    /// call delegate's peripheralDidConnect method and try to read values
    /// of LED and Button.
    private func enableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Enabling notifications for \(characteristic.uuid) characteristic...")
            basePeripheral.setNotifyValue(true, for: characteristic)
        } else {
            print("Can't enable notifications for characterestic \(characteristic.uuid), characteristic doesn't contain NOTIFY property")
        }
    }
    
    // Using a custom color-constructor of packages
    // because color data does not fit into a regular packet
    private func writeColor(color value: UIColor) {
        let packet = packetManager.createRGBPacket(color: value)
        writeCharacteristic(packet: packet)
    }
    
    private func writeData(_ register: Int, _ value: Int) {
        let packet = packetManager.createPacket(command: Sratocol.Device.Command.WRITE, for: UInt8(register), with: value)
        writeCharacteristic(packet: packet)
    }
    
    private func writeCharacteristic(packet: [UInt8]) {
        let data = Data(bytes: packet, count: packet.count)
        if let rxCharacteristic = rxCharacteristic {
            if rxCharacteristic.properties.contains(.writeWithoutResponse) {
                print("Writing (without response) \(packet)")
                basePeripheral.writeValue(data, for: rxCharacteristic, type: .withoutResponse)
                // Calling didWriteData because we are writing without response
                // didWriteData(data)
            } else if rxCharacteristic.properties.contains(.write) {
                print("Writing (with response) \(packet)")
                basePeripheral.writeValue(data, for: rxCharacteristic, type: .withResponse)
            } else {
                print("RX Characteristic is not writable")
            }
        }
    }
    
    /// A callback called when the TX characteristic value has changed.
    private func didReceiveData(withValue value: Data) {
        Sratocol.shared.delegate = self
        Sratocol.shared.getData(value)
    }

    private func parseAdvertisementData(_ advertisementDictionary: [String : Any]) -> String? {
        var advertisedName: String

        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "Unknown Device".localized
        }
        
        return advertisedName
    }
    
    // MARK: - NSObject protocols
    
    override func isEqual(_ object: Any?) -> Bool {
        if object is EasyPeripheral {
            let peripheralObject = object as! EasyPeripheral
            return peripheralObject.basePeripheral.identifier == basePeripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == basePeripheral.identifier
        } else {
            return false
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
            baseDelegate?.peripheralDidDisconnect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == basePeripheral {
            print("Connected to \(advertisedName ?? "device")")
            discoverUARTServices()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == basePeripheral {
            print("\(advertisedName ?? "Device") disconnected")
            baseDelegate?.peripheralDidDisconnect()
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == txCharacteristic {
            if let value = characteristic.value {
                didReceiveData(withValue: value)
            }
        }
        if characteristic == rxCharacteristic {
            if let value = characteristic.value {
                print("RX characteristic value updated: \(value)")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == txCharacteristic {
            print("TX notification enabled \(String(describing: characteristic.value))")
            baseDelegate?.peripheralIsReady(isReady: true)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == EasyPeripheral.UART_serviceUUID {
                    print("UART service found")
                    discoverCharacteristicsForUARTService(service)
                    return
                } else {
                    // Services has not been found
                    print("Services has not been found")
                    baseDelegate?.peripheralIsReady(isReady: false)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == EasyPeripheral.TX_characteristicUUID {
                    print("TX characteristic found")
                    txCharacteristic = characteristic
                    enableNotifications(for: characteristic)
                }
                if characteristic.uuid == EasyPeripheral.RX_characteristicUUID {
                    print("RX characteristic found")
                    rxCharacteristic = characteristic
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic {
        case rxCharacteristic:
            print("Data written successfully")
            break
        default:
            print("Did successful write for Unknown characteristic (\(characteristic.uuid))")
        }
    }
    
    private func notifyData(from characteristic: CBCharacteristic) -> Any {
      guard let characteristicData = characteristic.value else {return -1}
      let byteArray = [UInt8](characteristicData)

      return byteArray
    }
    
    // MARK: - Sratocol delegate
    
    func peripheralSettingsFlag(_ isConfigured: Bool) {
        baseDelegate?.peripheralConfigured(isConfigured)
        print("Settings flag: \(isConfigured)")
    }
    
    func isPeripheralSettingsReceived(_ isReceived: Bool) {
        baseDelegate?.peripheralSettingsReceived(isReceived)
    }
    
    func onError(_ register: Int, _ code: Int) {
        baseDelegate?.peripheralError(register, code)
    }
    
    func peripheralLEDColor(_ color: UIColor) {
        baseDelegate?.peripheralLEDColor(color)
    }
    
    func peripheralAnimationMode(_ mode: Int) {
        baseDelegate?.peripheralAnimationMode(mode)
    }
    
    func peripheralAnimationOnSpeed(_ speed: Int) {
        baseDelegate?.peripheralAnimationOnSpeed(speed)
    }
    
    func peripheralAnimationOffSpeed(_ speed: Int) {
        baseDelegate?.peripheralAnimationOffSpeed(speed)
    }
    
    func peripheralRandomColorMode(_ mode: Int) {
        baseDelegate?.peripheralRandomColorMode(mode)
    }
    
    func peripheralAdaptiveBrightnessMode(_ mode: Int) {
        baseDelegate?.peripheralAdaptiveBrightnessMode(mode == 1)
    }
    
    func peripheralDayNightMode(_ mode: Int) {
        baseDelegate?.peripheralDayNightMode(mode)
    }
    
    func peripheralDayNightModeOnTime(_ time: Int) {
        baseDelegate?.peripheralDayNightModeOnTime(time)
    }
    
    func peripheralDayNightModeOffTime(_ time: Int) {
        baseDelegate?.peripheralDayNightModeOffTime(time)
    }
    
    func peripheralStripType(_ type: Int) {
        extendedDelegate?.peripheralStripType(EasyData.stripType.allCases[type])
    }
    
    func peripheralStepsCount(_ count: Int) {
        baseDelegate?.peripheralStepsCount(count)
    }
    
    func peripheralBotSensorCurrentDistance(_ distance: Int) {
        extendedDelegate?.peripheralBotSensorCurrentDistance(distance)
    }
    
    func peripheralTopSensorCurrentDistance(_ distance: Int) {
        extendedDelegate?.peripheralTopSensorCurrentDistance(distance)
    }
    
    func peripheralBotSensorTriggerDistance(_ distance: Int) {
        extendedDelegate?.peripheralBotSensorTriggerDistance(distance)
    }
    
    func peripheralTopSensorTriggerDistance(_ distance: Int) {
        extendedDelegate?.peripheralTopSensorTriggerDistance(distance)
    }
    
    func peripheralBotSensorLocation(_ location: Int) {
        extendedDelegate?.peripheralBotSensorDirection(location)
    }
    
    func peripheralTopSensorLocation(_ location: Int) {
        extendedDelegate?.peripheralTopSensorDirection(location)
    }
    
}

struct EasyData {
    static let animationModes:  [Int:String] = [1: "Step by step", 2: "Sharp", 3: "Wave"]
    static let randomColorModes:[Int:String] = [1: "Off", 2: "Stairway", 3: "Step"]
    static let dayNightModes:   [Int:String] = [1: "Off", 2: "By time", 3: "By lightness"]
    static let sensorDirection: [Int:String] = [1: "Right", 2: "Left", 3: "Center"]
    enum stripType: Int, CaseIterable {
        case DEFAULT = 0
        case RGB     = 1
    }
    enum sensorLocation: Int, CaseIterable {
        case bot = 0
        case top = 1
    }
    
}

// MARK: - Making setup methods optional

extension EasyExtendedDelegate {
    func peripheralStripType(_ type: EasyData.stripType) {}
    func peripheralBotSensorCurrentDistance(_ distance: Int) {}
    func peripheralTopSensorCurrentDistance(_ distance: Int) {}
    func peripheralBotSensorTriggerDistance(_ distance: Int) {}
    func peripheralTopSensorTriggerDistance(_ distance: Int) {}
    func peripheralBotSensorDirection(_ direction: Int) {}
    func peripheralTopSensorDirection(_ direction: Int) {}
}

