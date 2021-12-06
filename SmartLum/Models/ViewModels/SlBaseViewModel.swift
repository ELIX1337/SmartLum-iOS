//
//  SlBaseViewModel.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlBaseViewModel: PeripheralViewModel {
    
    var topTriggerDistanceCell: CellModel!
    var botTriggerDistanceCell: CellModel!
    var ledStateCell:           CellModel!
    var ledBrightnessCell:      CellModel!
    var ledTimeoutCell:         CellModel!
    var animationSpeedCell:     CellModel!
    var resetToFactoryCell:     CellModel!
        
    var slBasePeripheral: SlBasePeripheral! {
        get { return (super.basePeripheral as! SlBasePeripheral) }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        slBasePeripheral.delegate = self
        dataModel = SlBaseData.init(values: [:])
        self.topTriggerDistanceCell = .sliderCell(
            key: SlBaseData.topTriggerDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.sensorMinDistance),
            maxValue: Float(SlBaseData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopSensorTriggerDistance(distance: Int($0)) })
        self.botTriggerDistanceCell = .sliderCell(
            key: SlBaseData.botTriggerDistanceKey,
            title: "peripheral_bot_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.sensorMinDistance),
            maxValue: Float(SlBaseData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotSensorTriggerDistance(distance: Int($0)) })
        self.ledStateCell = .switchCell(
            key: SlBaseData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: dataModel.getValue(key: SlBaseData.ledStateKey) as? Bool ?? false,
            callback: { self.writeLedState(state: $0) })
        self.ledBrightnessCell = .sliderCell(
            key: SlBaseData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: SlBaseData.ledBrightnessKey) as? Float ?? 0),
            minValue: Float(SlBaseData.ledMinBrightness),
            maxValue: Float(SlBaseData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        self.ledTimeoutCell = .stepperCell(
            key: SlBaseData.ledTimeout,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 1,
            minValue: Double(SlBaseData.ledMinTimeout),
            maxValue: Double(SlBaseData.ledMaxTimeout),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
        self.animationSpeedCell = .sliderCell(
            key: SlBaseData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: 1,
            minValue: Float(SlBaseData.animationMinSpeed),
            maxValue: Float(SlBaseData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
        self.resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
        initReadyTableViewModel()
        initSetupTableViewModel()
        initSettingsTableViewModel()
    }
    
    private func initReadyTableViewModel() {
        readyTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_led_state_section_header".localized,
                    footerText: "peripheral_led_state_section_footer".localized,
                    rows: [ledStateCell]),
                SectionModel(
                    headerText: "peripheral_led_brightness_section_header".localized,
                    footerText: "peripheral_led_brightness_section_footer".localized,
                    rows: [ledBrightnessCell]),
                SectionModel(
                    headerText: "peripheral_additional_section_header".localized,
                    footerText: "peripheral_additional_section_footer".localized,
                    rows: [animationSpeedCell,
                           ledTimeoutCell])
            ], type: .ready)
    }
    
    private func initSetupTableViewModel() {
        setupTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_setup_trigger_distance_section_header".localized,
                    footerText: "peripheral_setup_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell])
            ], type: .setup)
    }
    
    private func initSettingsTableViewModel() {
        settingsTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_sensor_trigger_distance_section_header".localized,
                    footerText: "peripheral_sensor_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell])
            ], type: .settings)
    }
    
    public func writeLedState(state: Bool) {
        dataModel.setValue(key: SlBaseData.ledStateKey, value: state)
        slBasePeripheral.writeLedState(state)
        updateCell(for: ledStateCell, with: .none)
    }
    
    public func writeLedBrightness(value: Int) {
        dataModel.setValue(key: SlBaseData.ledBrightnessKey, value: value)
        slBasePeripheral.writeLedBrightness(value)
        updateCell(for: ledBrightnessCell, with: .none)
    }
    
    public func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlBaseData.ledTimeout, value: timeout)
        slBasePeripheral.writeLedTimeout(timeout)
        updateCell(for: ledTimeoutCell, with: .none)
    }
    
    public func writeAnimationSpeed(speed: Int) {
        dataModel.setValue(key: SlBaseData.animationSpeedKey, value: speed)
        slBasePeripheral.writeAnimationOnSpeed(speed)
        updateCell(for: animationSpeedCell, with: .none)
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
    
    public func writeTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: distance)
        if isInitialized {
            slBasePeripheral.writeTopSensorTriggerDistance(distance)
        } else {
            checkInitWrite()
        }
    }
    
    public func writeBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: distance)
        if isInitialized {
            slBasePeripheral.writeBotSensorTriggerDistance(distance)
        } else {
            checkInitWrite()
        }
    }
    
    private func initTopSensorTriggerDistance(distance: Int) {
        readyToWriteInitData = dataModel.getValue(key: SlBaseData.botTriggerDistanceKey) as! Int != 0
    }
    
    private func initBotSensorTriggerDistance(distance: Int) {
        readyToWriteInitData = dataModel.getValue(key: SlBaseData.topTriggerDistanceKey) as! Int != 0
    }
    
    override func requiresInit() -> Bool {
        let first  = dataModel.getValue(key: SlBaseData.botTriggerDistanceKey) as? Int != 0
        let second = dataModel.getValue(key: SlBaseData.topTriggerDistanceKey) as? Int != 0
        return first && second
    }
    
}

extension SlBaseViewModel: SlBasePeripheralDelegate {
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: SlBaseData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlBaseData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlBaseData.ledTimeout, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: SlBaseData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlBaseData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
    }
    
    // Unused
    func getAnimationMode(mode: PeripheralDataElement) { }
    
    func getAnimationOffSpeed(speed: Int) { }
    
    func getAnimationDirection(direction: PeripheralDataElement) { }
    
    func getAnimationStep(step: Int) { }
    
}


