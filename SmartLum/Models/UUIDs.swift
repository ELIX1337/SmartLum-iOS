//
//  UUIDs.swift
//  SmartLum
//
//  Created by ELIX on 15.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth
public class UUIDs {
    
    // MARK: - Advertising UUIDs
    public static let TORCHERE_ADVERTISING_UUID = CBUUID.init(string: "BB930001-3CE1-4720-A753-28C0159DC777")
    public static let FL_MINI_ADVERTISING_UUID  = CBUUID.init(string: "BB930002-3CE1-4720-A753-28C0159DC777")
    public static let DIPLOM_ADVERTISING_UUID   = CBUUID.init(string: "00001523-1212-EFDE-1523-785FEABCD123")

    // MARK: - Services UUIDs
//    public static let DEVICE_INFO_SERVICE_UUID = CBUUID.init(string: "BB93FFFF-3CE1-4720-A753-28C0159DC777")
    public static let DEVICE_INFO_SERVICE_UUID = CBUUID.init(string: "00001526-1212-EFDE-1523-785FEABCD123")
    public static let COLOR_SERVICE_UUID       = CBUUID.init(string: "BB930B00-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_SERVICE_UUID   = CBUUID.init(string: "BB930A00-3CE1-4720-A753-28C0159DC777")
    public static let ENVIRONMENT_SERVICE_UUID = CBUUID.init(string: "00001527-1212-EFDE-1523-785FEABCD123")
    public static let DISTANCE_SERVICE_UUID    = CBUUID.init(string: "00001528-1212-EFDE-1523-785FEABCD123")
    public static let INDICATION_SERVICE_UUID  = CBUUID.init(string: "00001529-1212-EFDE-1523-785FEABCD123")

    // MARK: - Characteristics UUIDs
    // Device info service
    //public static let DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID = CBUUID.init(string: "BB93FFFE-3CE1-4720-A753-28C0159DC777")
    public static let DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID = CBUUID.init(string: "00001530-1212-EFDE-1523-785FEABCD123")
    public static let DEVICE_DFU_CHARACTERISTIC_UUID              = CBUUID.init(string: "BB93FFFD-3CE1-4720-A753-28C0159DC777")
    
    // Color service
    public static let COLOR_PRIMARY_CHARACTERISTIC_UUID   = CBUUID.init(string: "BB930B01-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_SECONDARY_CHARACTERISTIC_UUID = CBUUID.init(string: "BB930B02-3CE1-4720-A753-28C0159DC777")
    public static let COLOR_RANDOM_CHARACTERISTIC_UUID    = CBUUID.init(string: "BB930B03-3CE1-4720-A753-28C0159DC777")
    
    // Animation service
    public static let ANIMATION_MODE_CHARACTERISTIC_UUID      = CBUUID.init(string: "BB930A01-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_ON_SPEED_CHARACTERISTIC_UUID  = CBUUID.init(string: "BB930A02-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID = CBUUID.init(string: "BB930A03-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_DIRECTION_CHARACTERISTIC_UUID = CBUUID.init(string: "BB930A04-3CE1-4720-A753-28C0159DC777")
    public static let ANIMATION_STEP_CHARACTERISTIC_UUID      = CBUUID.init(string: "BB930A05-3CE1-4720-A753-28C0159DC777")
    
    // Distance service
    public static let DISTANCE_CHARACTERISTIC_UUID         = CBUUID.init(string: "00001544-1212-EFDE-1523-785FEABCD123")
    
    // Indication service
    public static let BUTTON_STATE_CHARACTERISTIC_UUID     = CBUUID.init(string: "00001524-1212-EFDE-1523-785FEABCD123")
    public static let LED_STATE_CHARACTERISTIC_UUID        = CBUUID.init(string: "00001525-1212-EFDE-1523-785FEABCD123")

    // Environment service
    public static let TEMPERATURE_CHARACTERISTIC_UUID      = CBUUID.init(string: "00001542-1212-EFDE-1523-785FEABCD123")
    public static let LIGHTNESS_CHARACTERISTIC_UUID        = CBUUID.init(string: "00001533-1212-EFDE-1523-785FEABCD123")

}

extension UUIDs {
    static let advServices:[CBUUID:BasePeripheral.Type] = [BluetoothEndpoint.AdvertisingServices.flClassic.uuid : TorcherePeripheral.self,
                                                           BluetoothEndpoint.AdvertisingServices.flMini.uuid   : TorcherePeripheral.self]
}
