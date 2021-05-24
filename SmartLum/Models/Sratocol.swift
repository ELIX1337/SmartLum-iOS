//
//  Sratocol.swift
//  SmartLum
//
//  Created by Tim on 26/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import UIKit

protocol SratocolDelegate {
    func peripheralSettingsFlag(_ isConfigured: Bool)
    func isPeripheralSettingsReceived(_ isReceived: Bool)
    func onError(_ register:Int, _ code:Int)
    func peripheralLEDColor(_ color: UIColor)
    func peripheralAnimationMode(_ mode: Int)
    func peripheralAnimationOnSpeed(_ speed: Int)
    func peripheralAnimationOffSpeed(_ speed: Int)
    func peripheralRandomColorMode(_ mode: Int)
    func peripheralAdaptiveBrightnessMode(_ mode: Int)
    func peripheralDayNightMode(_ mode: Int)
    func peripheralDayNightModeOnTime(_ time: Int)
    func peripheralDayNightModeOffTime(_ time: Int)
    func peripheralStripType(_ type: Int)
    func peripheralStepsCount(_ count: Int)
    func peripheralBotSensorCurrentDistance(_ distance: Int)
    func peripheralTopSensorCurrentDistance(_ distance: Int)
    func peripheralBotSensorTriggerDistance(_ distance: Int)
    func peripheralTopSensorTriggerDistance(_ distance: Int)
    func peripheralBotSensorLocation(_ location: Int)
    func peripheralTopSensorLocation(_ location: Int)
}

public final class Sratocol {
    
    // MARK: - Packet properties
    
    var packet = [UInt8](repeating: 0, count: 9)
    var CRC16: Int = 0
    
    // MARK: - Delegate
    var delegate: SratocolDelegate?
    
    // MARK: - Singletone constructor
    
    static let shared: Sratocol = {
        let instance = Sratocol()
        return instance
    }()
    
    private init() {}
    
    // MARK: - Public API
    
    func getData(_ data: Data) {
        let array = [UInt8](data)
        if let packet = unpackPacket(received: array) {
            packetParser(packet)
        }
    }
    
    func unpackPacket(received packet:[UInt8]) -> [Int]? {
        // If received packet contains RGB color
        if packet[Index.COMMAND] == Device.Command.RGB {
            return unpackRGBPacket(received: packet)
        }
        // if packet has 2 data bytes
        if packet[Index.B.DATA_COUNT] == 2 {
            var crcRX:UInt16 = UInt16(packet[Index.B.CRC_1])
            crcRX <<= 8
            crcRX |= UInt16(packet[Index.B.CRC_2])
            // Checking CRC for packet integrity
            if crcRX == setCRC(packet: packet) {
                var mPacket = [Int](repeating: 0, count: 3)
                mPacket[0] = Int(packet[Index.COMMAND])
                mPacket[1] = Int(packet[Index.REGISTER])
                var a:UInt16
                a = UInt16(packet[Index.B.DATA_1])
                a <<= 8
                a |= UInt16(packet[Index.B.DATA_2])
                mPacket[2] = Int(a)
                print("DATA CHECK - \(a)")
                print("Packet = \(packet)")
                return mPacket
            } else {
                print("CRC check FAILED, packet: \(packet) - \(crcRX)")
                return nil
            }
        // If packet has 1 data byte
        } else {
            var crcRX:UInt16 = UInt16(packet[Index.S.CRC_1])
            crcRX <<= 8
            crcRX |= UInt16(packet[Index.S.CRC_2])
            // Checking CRC for packet integrity
            if crcRX == setCRC(packet: packet) {
                var mPacket = [Int](repeating: 0, count: 3)
                mPacket[0] = Int(packet[Index.COMMAND])
                mPacket[1] = Int(packet[Index.REGISTER])
                mPacket[2] = Int(packet[Index.S.DATA_1])
                return mPacket
            } else {
                print("CRC check FAILED, packet: \(packet) - \(crcRX)")
                return nil
            }
        }
    }
    
    func createPacket(command: Int, for register: UInt8, with value: Int) -> [UInt8] {
        packet[Index.DATA_RECEIVER] = UInt8(Device.Address.MAIN_BLOCK)
        packet[Index.DATA_TRANSMITTER] = UInt8(Device.Address.APP)
        packet[Index.COMMAND] = UInt8(command)
        packet[Index.REGISTER] = register
        if value > 255 {
            packet[Index.B.DATA_COUNT]  = 2
            packet[Index.B.DATA_1]      = UInt8(value >> 8)
            packet[Index.B.DATA_2]      = UInt8(value & 0xFF)
            CRC16 = setCRC(packet: packet)
            packet[Index.B.CRC_1]       = UInt8(CRC16 >> 8)
            packet[Index.B.CRC_2]       = UInt8(CRC16 & 0xFF)
        } else {
            packet[Index.S.DATA_COUNT]  = 1
            packet[Index.S.DATA_1]      = UInt8(value)
            CRC16 = setCRC(packet: packet)
            packet[Index.S.CRC_1]       = UInt8(CRC16 >> 8)
            packet[Index.S.CRC_2]       = UInt8(CRC16 & 0xFF)
            packet[Index.S.EMPTY_BYTE]  = 0
        }
        return packet
    }
    
    func createResetPacket() -> [UInt8] {
        packet[Index.DATA_RECEIVER]     = UInt8(Device.Address.MAIN_BLOCK)
        packet[Index.DATA_TRANSMITTER]  = UInt8(Device.Address.APP)
        packet[Index.COMMAND]           = UInt8(Device.Command.HARD_RESET)
        packet[Index.REGISTER]          = UInt8(Device.Register.NULL)
        packet[Index.DATA_COUNT]        = 1
        packet[Index.S.DATA_1]          = 1
        CRC16                           = setCRC(packet: packet)
        packet[Index.S.CRC_1]           = UInt8(CRC16 >> 8)
        packet[Index.S.CRC_2]           = UInt8(CRC16 & 0xFF)
        packet[Index.S.EMPTY_BYTE]      = 0
        
        return packet
    }
    
    func createSettingsRequestPacket() -> [UInt8] {
        packet[Index.DATA_RECEIVER]     = UInt8(Device.Address.MAIN_BLOCK)
        packet[Index.DATA_TRANSMITTER]  = UInt8(Device.Address.APP)
        packet[Index.COMMAND]           = UInt8(Device.Command.GET_SETTINGS)
        packet[Index.REGISTER]          = 1
        packet[Index.DATA_COUNT]        = 1
        packet[Index.S.DATA_1]          = 0
        CRC16                           = setCRC(packet: packet)
        packet[Index.S.CRC_1]           = UInt8(CRC16 >> 8)
        packet[Index.S.CRC_2]           = UInt8(CRC16 & 0xFF)
        packet[Index.S.EMPTY_BYTE]      = 0
        
        return packet
    }
    
    // Crutch for color management (protocol sucks)
    func createRGBPacket(color: UIColor) -> [UInt8] {
        print("RGB COLOR - \(color)")
        packet[Index.DATA_RECEIVER]     = UInt8(Device.Address.MAIN_BLOCK)
        packet[Index.DATA_TRANSMITTER]  = UInt8(Device.Address.APP)
        packet[Index.COMMAND]           = UInt8(Device.Command.RGB)
        packet[Index.REGISTER]          = UInt8(color.rgb()!.red * 255)
        packet[Index.DATA_COUNT]        = 2
        packet[Index.B.DATA_1]          = UInt8(color.rgb()!.green * 255)
        packet[Index.B.DATA_2]          = UInt8(color.rgb()!.blue * 255)
        CRC16                           = setCRC(packet: packet)
        packet[Index.B.CRC_1]           = UInt8(CRC16 >> 8)
        packet[Index.B.CRC_2]           = UInt8(CRC16 & 0xFF)
        
        return packet
    }
    
    private func unpackRGBPacket(received packet: [UInt8]) -> [Int]? {
        var crcRX:UInt16 = UInt16(packet[Index.B.CRC_1])
        crcRX <<= 8
        crcRX |= UInt16(packet[Index.B.CRC_2])
        if crcRX == setCRC(packet: packet) {
            var mPacket = [Int](repeating: 0, count: 4)
            mPacket[0] = Int(packet[Index.COMMAND])
            mPacket[1] = Int(packet[Index.REGISTER]) // R
            mPacket[2] = Int(packet[Index.B.DATA_1]) // G
            mPacket[3] = Int(packet[Index.B.DATA_2]) // B
            return mPacket
        } else {
            print("CRC check FAILED, packet: \(packet)")
            return nil
        }
    }
    
    // If strip type is default, brightness handles from R channel
    func createBrightnessPacket(brightness value: Int) -> [UInt8] {
        packet[Index.DATA_RECEIVER]     = UInt8(Device.Address.MAIN_BLOCK)
        packet[Index.DATA_TRANSMITTER]  = UInt8(Device.Address.APP)
        packet[Index.COMMAND]           = UInt8(Device.Command.RGB)
        packet[Index.REGISTER]          = UInt8(value)
        packet[Index.DATA_COUNT]        = 2
        packet[Index.B.DATA_1]          = 0
        packet[Index.B.DATA_2]          = 0
        CRC16                           = setCRC(packet: packet)
        packet[Index.B.CRC_1]           = UInt8(CRC16 >> 8)
        packet[Index.B.CRC_2]           = UInt8(CRC16 & 0xFF)
        
        return packet
    }
    
    // MARK: - Packet structure
    
    struct Index {
        static let DATA_RECEIVER       = 0
        static let DATA_TRANSMITTER    = 1
        static let COMMAND             = 2
        static let REGISTER            = 3
        static let DATA_COUNT          = 4
        struct S {
            static let DATA_COUNT  = 4
            static let DATA_1      = 5
            static let CRC_1       = 6
            static let CRC_2       = 7
            static let EMPTY_BYTE  = 8
        }
        struct B {
            static let DATA_COUNT  = 4
            static let DATA_1      = 5
            static let DATA_2      = 6
            static let CRC_1       = 7
            static let CRC_2       = 8
        }
    }
    
    struct Device {
        struct Address {
            static let MAIN_BLOCK: Int   = 0xB3
            static let UPPER_SENSOR: Int = 0xB4
            static let APP: Int          = 0xB6
            static let NRF: Int          = 0xB6
            static let PC: Int           = 0xBD
        }
        struct Command {
            static let REQUEST_DESCONNECT       = 0x00
            static let READ: Int              = 0x01
            static let WRITE: Int             = 0x02
            static let ERROR: Int             = 0x03
            static let GET_SETTINGS: Int      = 0x04
            static let RGB: Int               = 0x05
            static let HARD_RESET: Int        = 0x10
            static let END_OF_SETTINGS: Int   = 0x11
        }
        struct Register {
            static let NULL: Int                          = 0
            static let SETTINGS_FLAG: Int                 = 1
            static let BRIGHTNESS: Int                    = 2
            static let ANIMATION: Int                     = 3
            static let DELAY: Int                         = 4
            static let BOT_SENS_DIRECTION: Int            = 5
            static let TOP_SENS_DIRECTION: Int            = 6
            static let BOT_SENS_TRIGGER_DISTANCE: Int     = 7
            static let TOP_SENS_TRIGGER_DISTANCE: Int     = 8
            static let RANDOM_COLOR_MODE: Int             = 12
            static let STEPS_COUNT: Int                   = 13
            static let STRIP_TYPE: Int                    = 15
            static let SENS_TYPE: Int                     = 16
            static let CLOCK: Int                         = 17
            static let ANIMATION_ON_SPEED: Int            = 19
            static let ANIMATION_OFF_SPEED: Int           = 20
            static let ADAPTIVE_BRIGHTNESS_MODE: Int      = 21
            static let ALARM_A: Int                       = 23
            static let ALARM_B: Int                       = 24
            static let DAY_NIGHT_MODE: Int                = 25
            static let BOT_SENS_CURRENT_LIGHTNESS: Int    = 28
            static let BOT_SENS_CURRENT_DISTANCE: Int     = 29
            static let TOP_SENS_CURRENT_LIGHTNESS: Int    = 31
            static let TOP_SENS_CURRENT_DISTANCE: Int     = 32

            // Unused registers
            static let COLOR_RED: Int       = 9
            static let COLOR_GREEN: Int     = 10
            static let COLOR_BLUE: Int      = 11
            static let STAIRS_OFF_DELAY       = 14
            static let SERIAL_TYPE: Int     = 0x0C
            static let SERIAL_CAT: Int      = 0x0D
            static let SERIAL_BLOCK: Int    = 0x0E
            static let SERIAL_SYMBOL_1: Int = 0x0F
            static let SERIAL_SYMBOL_2: Int = 0x10
            static let SERIAL_SYMBOL_3: Int = 0x11
        }
    }
    
    // MARK: - CRC
    
    private func setCRC(packet: [UInt8]) -> Int {
        var crc: Int = 0xFFFF
        
        if (packet[4] == 2) {
            for i in 0..<packet.count-2 {
                crc = ((crc >> 8) | (crc << 8)) & 0xFFFF
                crc ^= (Int(packet[i]) & 0xFF)
                crc ^= ((crc & 0xFF) >> 4)
                crc ^= (crc << 12) & 0xFFFF
                crc ^= ((crc & 0xFF) << 5) & 0xFFFF
            }
            crc &= 0xFFFF
            return crc
            
        } else if (packet[4] == 1) {
            for i in 0..<packet.count-3 {
                crc = ((crc >> 8) | (crc << 8)) & 0xFFFF
                crc ^= (Int(packet[i]) & 0xFF)
                crc ^= ((crc & 0xFF) >> 4)
                crc ^= (crc << 12) & 0xFFFF
                crc ^= ((crc & 0xFF) << 5) & 0xFFFF
            }
            crc &= 0xFFFF
            return crc
            
        } else {
            return 0
        }
    }
    
    // MARK: - Parcing incoming packets
    
    private func packetParser(_ packet: [Int]) {
        switch (packet[0]) {
            case Sratocol.Device.Command.WRITE:
                dataParcer(packet[1], packet[2])
                print("Packet parcer \(packet[2])")
                break
            case Sratocol.Device.Command.READ:
                // Never comes
                break
            case Sratocol.Device.Command.RGB:
                rgbPacketParcer(packet)
                break
            case Sratocol.Device.Command.END_OF_SETTINGS:
                delegate?.isPeripheralSettingsReceived(true)
                break
            case Sratocol.Device.Command.ERROR:
                break
            default:
                print("Unknown data")
        }
    }
    
    private func dataParcer(_ register: Int, _ value: Int) {
        switch register {
            case Sratocol.Device.Register.SETTINGS_FLAG:
                delegate?.peripheralSettingsFlag(value == 1)
                break
            case Sratocol.Device.Register.ANIMATION:
                delegate?.peripheralAnimationMode(Int(value))
                break
            case Sratocol.Device.Register.ANIMATION_ON_SPEED:
                delegate?.peripheralAnimationOnSpeed(Int(value))
                break
            case Sratocol.Device.Register.ANIMATION_OFF_SPEED:
                delegate?.peripheralAnimationOffSpeed(Int(value))
                break
            case Sratocol.Device.Register.RANDOM_COLOR_MODE:
                delegate?.peripheralRandomColorMode(Int(value))
                break
            case Sratocol.Device.Register.ADAPTIVE_BRIGHTNESS_MODE:
                delegate?.peripheralAdaptiveBrightnessMode(Int(value))
                break
            case Sratocol.Device.Register.ALARM_A:
                delegate?.peripheralDayNightModeOnTime(Int(value))
                break
            case Sratocol.Device.Register.ALARM_B:
                delegate?.peripheralDayNightModeOffTime(Int(value))
                break
            case Sratocol.Device.Register.DAY_NIGHT_MODE:
                delegate?.peripheralDayNightMode(Int(value))
                break
            case Sratocol.Device.Register.BOT_SENS_CURRENT_DISTANCE:
                delegate?.peripheralBotSensorCurrentDistance(Int(value))
                break
            case Sratocol.Device.Register.TOP_SENS_CURRENT_DISTANCE:
                delegate?.peripheralTopSensorCurrentDistance(Int(value))
                break
            case Sratocol.Device.Register.BOT_SENS_TRIGGER_DISTANCE:
                print("Sratocol bot trigger distance \(value)")
                delegate?.peripheralBotSensorTriggerDistance(Int(value))
                break
            case Sratocol.Device.Register.TOP_SENS_TRIGGER_DISTANCE:
                print("Sratocol top trigger distance \(value)")
                delegate?.peripheralTopSensorTriggerDistance(Int(value))
                break
            case Sratocol.Device.Register.STEPS_COUNT:
                delegate?.peripheralStepsCount(Int(value))
                break
            case Sratocol.Device.Register.STRIP_TYPE:
                delegate?.peripheralStripType(Int(value))
                break
            case Sratocol.Device.Register.TOP_SENS_DIRECTION:
                delegate?.peripheralTopSensorLocation(Int(value))
                break
            case Sratocol.Device.Register.BOT_SENS_DIRECTION:
                delegate?.peripheralBotSensorLocation(Int(value))
                break
            default:
                print("Unknown data: register - \(register), value - \(value)")
                break
        }
    }
    
    private func rgbPacketParcer(_ packet: [Int]) {
        let red    = CGFloat(packet[1])
        let green  = CGFloat(packet[2])
        let blue   = CGFloat(packet[3])
        let color  = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
        delegate?.peripheralLEDColor(color)
    }
    
}

// MARK: - Singletones must not be cloned

extension Sratocol: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
