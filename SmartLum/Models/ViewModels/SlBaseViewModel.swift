//
//  SlBaseViewModel.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlBaseViewModel: PeripheralViewModel {
    
    private var topInitDistance: Int?
    private var botInitDistance: Int?
    
    var topTriggerDistanceCell: PeripheralCell!
    var botTriggerDistanceCell: PeripheralCell!
    var ledStateCell:           PeripheralCell!
    var ledBrightnessCell:      PeripheralCell!
    var ledTimeoutCell:         PeripheralCell!
    var animationSpeedCell:     PeripheralCell!
    var resetToFactoryCell:     PeripheralCell!
    
    var slBasePeripheral: SlBasePeripheral! {
        get { return (super.basePeripheral as! SlBasePeripheral) }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (PeripheralCell) -> Void) {
        super.init(withTableView, withPeripheral as! SlBasePeripheral, delegate, selected)
        self.slBasePeripheral.delegate = self
        self.tableView = withTableView
        self.selection = selected
        self.dataModel = SlBaseData.init(values: [:])
        self.topTriggerDistanceCell = .sliderCell(
            key: SlBaseData.topTriggerDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.sensorMinDistance),
            maxValue: Float(SlBaseData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        self.botTriggerDistanceCell = .sliderCell(
            key: SlBaseData.botTriggerDistanceKey,
            title: "peripheral_bot_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.sensorMinDistance),
            maxValue: Float(SlBaseData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        self.ledStateCell = .switchCell(
            key: SlBaseData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: dataModel.getValue(key: SlBaseData.ledStateKey) as? Bool ?? false )
        self.ledBrightnessCell = .sliderCell(
            key: SlBaseData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: SlBaseData.ledBrightnessKey) as? Float ?? 0),
            minValue: Float(SlBaseData.ledMinBrightness),
            maxValue: Float(SlBaseData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false)
        self.ledTimeoutCell = .stepperCell(
            key: SlBaseData.ledTimeout,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlBaseData.ledMinTimeout),
            maxValue: Double(SlBaseData.ledMaxTimeout))
        self.animationSpeedCell = .sliderCell(
            key: SlBaseData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.animationMinSpeed),
            maxValue: Float(SlBaseData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false)
        self.resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized)
        self.peripheralReadyTableViewModel = PeripheralTableViewModel(
            sections: [
                PeripheralSection(
                    headerText: "peripheral_led_state_section_header".localized,
                    footerText: "peripheral_led_state_section_footer".localized,
                    rows: [ledStateCell]),
                PeripheralSection(
                    headerText: "peripheral_led_brightness_section_header".localized,
                    footerText: "peripheral_led_brightness_section_footer".localized,
                    rows: [ledBrightnessCell]),
                PeripheralSection(
                    headerText: "peripheral_additional_section_header".localized,
                    footerText: "peripheral_additional_section_footer".localized,
                    rows: [animationSpeedCell,
                           ledTimeoutCell])
            ])
        self.peripheralSetupTableViewModel = PeripheralTableViewModel(
            sections: [
            PeripheralSection.init(
                headerText: "peripheral_setup_trigger_distance_section_header".localized,
                footerText: "peripheral_setup_trigger_distance_section_footer".localized,
                rows: [topTriggerDistanceCell,
                       botTriggerDistanceCell])
        ])
        self.peripheralSettingsTableViewModel = PeripheralTableViewModel(
            sections: [
            PeripheralSection.init(
                headerText: "peripheral_sensor_trigger_distance_section_header".localized,
                footerText: "peripheral_sensor_trigger_distance_section_footer".localized,
                rows: [topTriggerDistanceCell,
                       botTriggerDistanceCell]),
            PeripheralSection.init(
                headerText: "peripheral_factory_settings_section_header".localized,
                footerText: "peripheral_factory_settings_section_footer".localized,
                rows: [resetToFactoryCell])
        ])
    }
    
    override func cellDataCallback(fromRow: PeripheralCell, withValue: Any?) {
        super.cellDataCallback(fromRow: fromRow, withValue: withValue)
        switch fromRow {
        case ledStateCell:
            print("Led state - \(String(describing: withValue))")
            if let value = withValue as? Bool {
                slBasePeripheral.writeLedState(value)
                dataModel.setValue(key: fromRow.cellKey, value: value)
            }
            break
        case ledBrightnessCell:
            print("Brightness - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeLedBrightness(Int(value))
                dataModel.setValue(key: fromRow.cellKey, value: value)
            }
            break
        case ledTimeoutCell:
            print("Led timeout - \(String(describing: withValue))")
            if let value = withValue as? Int {
                slBasePeripheral.writeLedTimeout(value)
                dataModel.setValue(key: fromRow.cellKey, value: value)
            }
            break
        case animationSpeedCell:
            print("Animation speed - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeAnimationOnSpeed(Int(value))
                dataModel.setValue(key: fromRow.cellKey, value: value)
            }
            break
        case topTriggerDistanceCell:
            print("Top trigger - \(String(describing: withValue))")
            if let value = withValue as? Float {
                if (dataModel.getValue(key: BasePeripheralData.initStateKey) ?? false) as! Bool {
                    slBasePeripheral.writeTopSensorTriggerDistance(Int(value))
                    dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: Int(value))
                } else {
                    initTopSensorTriggerDistance(distance: Int(value))
                }
            }
            break
        case botTriggerDistanceCell:
            print("Bot trigger - \(String(describing: withValue))")
            if let value = withValue as? Float {
                if (dataModel.getValue(key: BasePeripheralData.initStateKey) ?? false) as! Bool {
                    slBasePeripheral.writeBotSensorTriggerDistance(Int(value))
                    dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: Int(value))
                } else {
                    initBotSensorTriggerDistance(distance: Int(value))
                }
            }
            break
        case resetToFactoryCell:
            selection(fromRow)
            print("RESET CELL")
            break
        default:
            print("Unkown cell - \(fromRow.cellKey)")
        }
    }
    
    public func writeInitDistance() -> Bool {
        if let top = dataModel.getValue(key: SlBaseData.topTriggerDistanceKey),
           let bot = dataModel.getValue(key: SlBaseData.botTriggerDistanceKey) {
            slBasePeripheral.writeTopSensorTriggerDistance(top as! Int)
            slBasePeripheral.writeBotSensorTriggerDistance(bot as! Int)
            return true
        }
        return false
    }
    
    public func initTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: distance)
        readyToWriteInitData = dataModel.getValue(key: SlBaseData.botTriggerDistanceKey) as! Int != 0
    }
    
    public func initBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: distance)
        readyToWriteInitData = dataModel.getValue(key: SlBaseData.topTriggerDistanceKey) as! Int != 0
    }
    
    public func writeTopSensorTriggerDistance(distance: Int) {
        slBasePeripheral.writeTopSensorTriggerDistance(distance)
        dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: distance)
        reloadCell(for: topTriggerDistanceCell, with: .none)
    }
    
    public func writeBotSensorTriggerDistance(distance: Int) {
        slBasePeripheral.writeBotSensorTriggerDistance(distance)
        dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: distance)
        reloadCell(for: botTriggerDistanceCell, with: .none)
    }
    
}

extension SlBaseViewModel: SlBasePeripheralDelegate {
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: SlBaseData.animationSpeedKey, value: speed)
        reloadCell(for: animationSpeedCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlBaseData.ledBrightnessKey, value: brightness)
        reloadCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlBaseData.ledTimeout, value: timeout)
        reloadCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: SlBaseData.ledStateKey, value: state)
        reloadCell(for: ledStateCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: distance)
        reloadCell(for: topTriggerDistanceCell, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: distance)
        reloadCell(for: botTriggerDistanceCell, with: .middle)
    }
    
    // Unused
    func getAnimationMode(mode: PeripheralAnimations) { }
    
    func getAnimationOffSpeed(speed: Int) { }
    
    func getAnimationDirection(direction: PeripheralAnimationDirections) { }
    
    func getAnimationStep(step: Int) { }
    
}

