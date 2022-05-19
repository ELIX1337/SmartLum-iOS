//
//  UUIDs.swift
//  SmartLum
//
//  Created by ELIX on 15.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Здесь описаны все UUID, котры используют устройства Smartlum.
/// Структура Bluetooth стека описана в данном докуенте
/// https://docs.google.com/spreadsheets/d/1IAUbWO-sd7CVY9ZWAEC8YQZ1yNzNt0rkT8BpPgPerYA/
public struct UUIDs: Error {
            
    // MARK: - Advertising UUIDs
    public static let FL_CLASSIC_ADVERTISING_UUID   = CBUUID(string: "BB930001-3CE1-4720-A753-28C0159DC777")
    public static let FL_MINI_ADVERTISING_UUID      = CBUUID(string: "BB930002-3CE1-4720-A753-28C0159DC777")
    public static let SL_BASE_ADVERTISING_UUID      = CBUUID(string: "BB930003-3CE1-4720-A753-28C0159DC777")
    public static let SL_STANDART_ADVERTISING_UUID  = CBUUID(string: "BB930004-3CE1-4720-A753-28C0159DC777")
    public static let SL_PRO_ADVERTISING_UUID       = CBUUID(string: "BB930005-3CE1-4720-A753-28C0159DC777")

    // MARK: - Services UUIDs
    public static let DEVICE_INFO_SERVICE_UUID = CBUUID(string: "FFFF")
    public static let ANIMATION_SERVICE_UUID   = CBUUID(string: "0A00")
    public static let COLOR_SERVICE_UUID       = CBUUID(string: "0B00")
    public static let LED_SERVICE_UUID         = CBUUID(string: "0C00")
    public static let SENSOR_SERVICE_UUID      = CBUUID(string: "0D00")
    public static let EVENT_SERVICE_UUID       = CBUUID(string: "0E00")
    public static let STAIRS_SERVICE_UUID      = CBUUID(string: "0F00")

    // MARK: - Characteristics UUIDs
    // Device info service
    public static let DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID = CBUUID(string: "FFFE")
    public static let DEVICE_DFU_CHARACTERISTIC_UUID              = CBUUID(string: "FFFD")
    public static let FACTORY_SETTINGS_CHARACTERISTIC_UUID        = CBUUID(string: "FFFC")
    public static let DEVICE_INIT_STATE_CHARACTERISTIC_UUID       = CBUUID(string: "FFFB")
    public static let DEVICE_DEMO_MODE_STATE_CHARACTERISTIC_UUID  = CBUUID(string: "FFFA")
    public static let DEVICE_SERIAL_NUMBER_CHARACTERISTIC_UUID    = CBUUID(string: "FFF0")
    
    // Event service
    public static let EVENT_ERROR_CHARACTERISTIC_UUID = CBUUID.init(string: "0E01")
    
    // Color service
    public static let COLOR_PRIMARY_CHARACTERISTIC_UUID   = CBUUID(string: "0B01")
    public static let COLOR_SECONDARY_CHARACTERISTIC_UUID = CBUUID(string: "0B02")
    public static let COLOR_RANDOM_CHARACTERISTIC_UUID    = CBUUID(string: "0B03")
    
    // Animation service
    public static let ANIMATION_MODE_CHARACTERISTIC_UUID      = CBUUID(string: "0A01")
    public static let ANIMATION_ON_SPEED_CHARACTERISTIC_UUID  = CBUUID(string: "0A02")
    public static let ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID = CBUUID(string: "0A03")
    public static let ANIMATION_DIRECTION_CHARACTERISTIC_UUID = CBUUID(string: "0A04")
    public static let ANIMATION_STEP_CHARACTERISTIC_UUID      = CBUUID(string: "0A05")
    
    // LED service
    public static let LED_STATE_CHARACTERISTIC_UUID      = CBUUID(string: "0C01")
    public static let LED_BRIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0C02")
    public static let LED_TIMEOUT_CHARACTERISTIC_UUID    = CBUUID(string: "0C03")
    public static let LED_TYPE_UUID                      = CBUUID(string: "0C04")
    public static let LED_ADAPTIVE_MODE_UUID             = CBUUID(string: "0C05")

    // Sensor service
    public static let TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "0D01")
    public static let BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "0D02")
    public static let TOP_SENSOR_CURRENT_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "0D03")
    public static let BOT_SENSOR_CURRENT_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "0D04")
    public static let TOP_SENSOR_TRIGGER_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0D05")
    public static let BOT_SENSOR_TRIGGER_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0D06")
    public static let TOP_SENSOR_CURRENT_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0D07")
    public static let BOT_SENSOR_CURRENT_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0D08")
    
    // Stairs service
    public static let STEPS_COUNT_CHARACTERISTIC_UUID                 = CBUUID(string: "0F01")
    public static let STANDBY_LIGHTING_STATE_CHARACTERISTIC_UUID      = CBUUID(string: "0F02")
    public static let STANDBY_LIGHTING_TOP_COUNT_CHARACTERISTIC_UUID  = CBUUID(string: "0F03")
    public static let STANDBY_LIGHTING_BOT_COUNT_CHARACTERISTIC_UUID  = CBUUID(string: "0F04")
    public static let STANDBY_LIGHTING_BRIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "0F05")
    public static let WORK_MODE_CHARACTERISTIC_UUID                   = CBUUID(string: "0F06")
    public static let TOP_SENSOR_COUNT                                = CBUUID(string: "0F07")
    public static let BOT_SENSOR_COUNT                                = CBUUID(string: "0F08")

    struct Legacy {

        // MARK: - Services UUIDs
        public static let DEVICE_INFO_SERVICE_UUID = CBUUID(string: "BB93FFFF-3CE1-4720-A753-28C0159DC777")
        public static let ANIMATION_SERVICE_UUID   = CBUUID(string: "BB930A00-3CE1-4720-A753-28C0159DC777")
        public static let COLOR_SERVICE_UUID       = CBUUID(string: "BB930B00-3CE1-4720-A753-28C0159DC777")
        public static let LED_SERVICE_UUID         = CBUUID(string: "BB930C00-3CE1-4720-A753-28C0159DC777")
        public static let SENSOR_SERVICE_UUID      = CBUUID(string: "BB930D00-3CE1-4720-A753-28C0159DC777")
        public static let EVENT_SERVICE_UUID       = CBUUID(string: "BB930E00-3CE1-4720-A753-28C0159DC777")
        public static let STAIRS_SERVICE_UUID      = CBUUID(string: "BB930F00-3CE1-4720-A753-28C0159DC777")

        // MARK: - Characteristics UUIDs
        // Device info service
        public static let DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID = CBUUID(string: "BB93FFFE-3CE1-4720-A753-28C0159DC777")
        public static let DEVICE_DFU_CHARACTERISTIC_UUID              = CBUUID(string: "BB93FFFD-3CE1-4720-A753-28C0159DC777")
        public static let FACTORY_SETTINGS_CHARACTERISTIC_UUID        = CBUUID(string: "BB93FFFC-3CE1-4720-A753-28C0159DC777")
        public static let DEVICE_INIT_STATE_CHARACTERISTIC_UUID       = CBUUID(string: "BB93FFFB-3CE1-4720-A753-28C0159DC777")
        public static let DEVICE_DEMO_MODE_STATE_CHARACTERISTIC_UUID  = CBUUID(string: "BB93FFFA-3CE1-4720-A753-28C0159DC777")
        public static let DEVICE_SERIAL_NUMBER_CHARACTERISTIC_UUID    = CBUUID(string: "BB93FFF0-3CE1-4720-A753-28C0159DC777")
        
        // Event service
        public static let EVENT_ERROR_CHARACTERISTIC_UUID = CBUUID(string: "BB930E01-3CE1-4720-A753-28C0159DC777")
        
        // Color service
        public static let COLOR_PRIMARY_CHARACTERISTIC_UUID   = CBUUID(string: "BB930B01-3CE1-4720-A753-28C0159DC777")
        public static let COLOR_SECONDARY_CHARACTERISTIC_UUID = CBUUID(string: "BB930B02-3CE1-4720-A753-28C0159DC777")
        public static let COLOR_RANDOM_CHARACTERISTIC_UUID    = CBUUID(string: "BB930B03-3CE1-4720-A753-28C0159DC777")
        
        // Animation service
        public static let ANIMATION_MODE_CHARACTERISTIC_UUID      = CBUUID(string: "BB930A01-3CE1-4720-A753-28C0159DC777")
        public static let ANIMATION_ON_SPEED_CHARACTERISTIC_UUID  = CBUUID(string: "BB930A02-3CE1-4720-A753-28C0159DC777")
        public static let ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID = CBUUID(string: "BB930A03-3CE1-4720-A753-28C0159DC777")
        public static let ANIMATION_DIRECTION_CHARACTERISTIC_UUID = CBUUID(string: "BB930A04-3CE1-4720-A753-28C0159DC777")
        public static let ANIMATION_STEP_CHARACTERISTIC_UUID      = CBUUID(string: "BB930A05-3CE1-4720-A753-28C0159DC777")
        
        // LED service
        public static let LED_STATE_CHARACTERISTIC_UUID      = CBUUID(string: "BB930C01-3CE1-4720-A753-28C0159DC777")
        public static let LED_BRIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "BB930C02-3CE1-4720-A753-28C0159DC777")
        public static let LED_TIMEOUT_CHARACTERISTIC_UUID    = CBUUID(string: "BB930C03-3CE1-4720-A753-28C0159DC777")
        public static let LED_TYPE_UUID                      = CBUUID(string: "BB930C04-3CE1-4720-A753-28C0159DC777")
        public static let LED_ADAPTIVE_MODE_UUID             = CBUUID(string: "BB930C05-3CE1-4720-A753-28C0159DC777")

        // Sensor service
        public static let TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "BB930D01-3CE1-4720-A753-28C0159DC777")
        public static let BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "BB930D02-3CE1-4720-A753-28C0159DC777")
        public static let TOP_SENSOR_CURRENT_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "BB930D03-3CE1-4720-A753-28C0159DC777")
        public static let BOT_SENSOR_CURRENT_DISTANCE_CHARACTERISTIC_UUID  = CBUUID(string: "BB930D04-3CE1-4720-A753-28C0159DC777")
        public static let TOP_SENSOR_TRIGGER_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "BB930D05-3CE1-4720-A753-28C0159DC777")
        public static let BOT_SENSOR_TRIGGER_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "BB930D06-3CE1-4720-A753-28C0159DC777")
        public static let TOP_SENSOR_CURRENT_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "BB930D07-3CE1-4720-A753-28C0159DC777")
        public static let BOT_SENSOR_CURRENT_LIGHTNESS_CHARACTERISTIC_UUID = CBUUID(string: "BB930D08-3CE1-4720-A753-28C0159DC777")
        
        // Stairs service
        public static let STEPS_COUNT_CHARACTERISTIC_UUID            = CBUUID(string: "BB930F01-3CE1-4720-A753-28C0159DC777")
        public static let STANDBY_LIGHTING_STATE_CHARACTERISTIC_UUID = CBUUID(string: "BB930F02-3CE1-4720-A753-28C0159DC777")
        public static let STANDBY_LIGHTING_TOP_COUNT                 = CBUUID(string: "BB930F03-3CE1-4720-A753-28C0159DC777")
        public static let STANDBY_LIGHTING_BOT_COUNT                 = CBUUID(string: "BB930F04-3CE1-4720-A753-28C0159DC777")
        public static let STANDBY_LIGHTING_BRIGHTNESS                = CBUUID(string: "BB930F05-3CE1-4720-A753-28C0159DC777")
        public static let WORK_MODE                                  = CBUUID(string: "BB930F06-3CE1-4720-A753-28C0159DC777")
        public static let TOP_SENSOR_COUNT                           = CBUUID(string: "BB930F07-3CE1-4720-A753-28C0159DC777")
        public static let BOT_SENSOR_COUNT                           = CBUUID(string: "BB930F08-3CE1-4720-A753-28C0159DC777")

    }

}

/// Здесь перечислены рекламные UUID в виде массива. Этот массив (ключи) передается в фильтр BLE сканнера.
/// Значения на самом деле не нужны и можно все привести к обычному массиву, просто было лень рефакторить.
extension UUIDs {
    
    static let advServices:[CBUUID] = [
        BluetoothEndpoint.AdvertisingServices.flClassic.uuid,
        BluetoothEndpoint.AdvertisingServices.flMini.uuid,
        BluetoothEndpoint.AdvertisingServices.slBase.uuid,
        BluetoothEndpoint.AdvertisingServices.slStandart.uuid,
        BluetoothEndpoint.AdvertisingServices.slPro.uuid
    ]
}
