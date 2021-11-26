//
//  SlStandartViewModel.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlStandartViewModel: PeripheralViewModel {
    
    // Color section
    var primaryColorCell: CellModel!
    var randomColorCell: CellModel!
    // LED section
    var ledStateCell: CellModel!
    var ledBrightnessCell: CellModel!
    var ledTimeoutCell: CellModel!
    // Animation section
    var animationModeCell: CellModel!
    var animationSpeedCell: CellModel!
    // Sensor section
    var topTriggerDistanceCell: CellModel!
    var botTriggerDistanceCell: CellModel!
    var topTriggerLightnessCell: CellModel!
    var botTriggerLightnessCell: CellModel!
    var topCurrentDistanceCell: CellModel!
    var botCurrentDistanceCell: CellModel!
    var topCurrentLightnessCell: CellModel!
    var botCurrentLightnessCell: CellModel!

    // Stairs section
    var stepsCountCell: CellModel!
    var standbyStateCell: CellModel!
    var standbyBrightnessCell: CellModel!
    var standbyTopCountCell: CellModel!
    var standbyBotCountCell: CellModel!
    // Factory section
    var resetToFactoryCell: CellModel!
    
    var primaryColor: UIColor {
        get {
            if let color = self.dataModel.getValue(key: SlStandartData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    var slStandartPeripheral: SlStandartPeripheral! {
        get { return (super.basePeripheral as! SlStandartPeripheral) }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral as! SlStandartPeripheral, delegate, selected)
        slStandartPeripheral.delegate = self
        self.tableViewDataSourceAndDelegate = self
        self.tableView = withTableView
        self.onCellSelected = selected
        self.dataModel = SlStandartData(values: [:])
        initColorSection()
        initLedSection()
        initAnimationSection()
        initSettingsSection()
    }
    
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: SlStandartData.primaryColorKey,
            title: "peripheral_primary_color_cell_title".localized,
            initialValue: UIColor.white, callback: { _ in })
    }
    
    private func initLedSection() {
        ledStateCell = .switchCell(
            key: SlStandartData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: false,
            callback: { self.writeLedState(state: $0) })
        ledBrightnessCell = .sliderCell(
            key: SlStandartData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(SlStandartData.ledMinBrightness),
            minValue: Float(SlStandartData.ledMinBrightness),
            maxValue: Float(SlStandartData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        ledTimeoutCell = .stepperCell(
            key: SlStandartData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.ledMinTimeout),
            maxValue: Double(SlStandartData.ledMaxTimeout),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
    }
    
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: SlStandartData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: "")
        animationSpeedCell = .sliderCell(
            key: SlStandartData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(SlStandartData.animationMinSpeed),
            minValue: Float(SlStandartData.animationMinSpeed),
            maxValue: Float(SlStandartData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
    }
    
    private func initSettingsSection() {
        topTriggerDistanceCell = .sliderCell(
            key: SlStandartData.topTriggerDistanceKey,
            title: "peripheral_sl_standart_top_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlStandartData.sensorMinDistance),
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerDistance(value: Int($0)) })
        botTriggerDistanceCell = .sliderCell(
            key: SlStandartData.botTriggerDistanceKey,
            title: "peripheral_sl_standart_bot_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlStandartData.sensorMinDistance),
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerDistance(value: Int($0)) })
        topTriggerLightnessCell = .sliderCell(
            key: SlStandartData.topTriggerLightnessKey,
            title: "peripheral_sl_standart_top_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerLightness(value: Int($0)) })
        botTriggerLightnessCell = .sliderCell(
            key: SlStandartData.botTriggerLightnessKey,
            title: "peripheral_sl_standart_bot_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerLightness(value: Int($0)) })
        topCurrentDistanceCell = .infoCell(
            key: SlStandartData.topCurrentDistanceKey,
            titleText: "Top current distance",
            detailText: "",
            image: nil,
            accessory: nil)
        botCurrentDistanceCell = .infoCell(
            key: SlStandartData.topCurrentDistanceKey,
            titleText: "Bot current distance",
            detailText: "",
            image: nil,
            accessory: nil)
        stepsCountCell = .stepperCell(
            key: SlStandartData.stepsCountKey,
            title: "peripheral_sl_standart_steps_count_cell".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.stepsMinCount),
            maxValue: Double(SlStandartData.stepsMaxCount),
            callback: { self.writeStepsCount(count: Int($0)) })
        standbyStateCell = .switchCell(
            key: SlStandartData.standbyStateKey,
            title: "peripheral_sl_standart_standby_state".localized,
            initialValue: false,
            callback: { self.writeStandbyState(state: $0) })
        standbyBrightnessCell = .sliderCell(
            key: SlStandartData.standbyBrightnessKey,
            title: "peripheral_sl_standart_standby_brightness".localized,
            initialValue: 0,
            minValue: Float(SlStandartData.ledMinBrightness),
            maxValue: Float(SlStandartData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeStandbyBrightness(value: Int($0)) })
        standbyTopCountCell = .stepperCell(
            key: SlStandartData.standbyTopCountKey,
            title: "peripheral_sl_standart_standby_top_count".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.standbyMinCount),
            maxValue: Double(SlStandartData.standbyMaxCount),
            callback: { self.writeStandbyTopCount(count: Int($0)) })
        standbyBotCountCell = .stepperCell(
            key: SlStandartData.standbyBotCountKey,
            title: "peripheral_sl_standart_standby_bot_count".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.standbyMinCount),
            maxValue: Double(SlStandartData.standbyMaxCount),
            callback: { self.writeStandbyBotCount(count: Int($0)) })
        resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
        topCurrentLightnessCell = .infoCell(
            key: SlStandartData.topCurrentLightnessKey,
            titleText: "Top lightness",
            detailText: nil,
            image: nil,
            accessory: nil)
        botCurrentLightnessCell = .infoCell(
            key: SlStandartData.botCurrentLightnessKey,
            titleText: "Bot lightness",
            detailText: nil,
            image: nil,
            accessory: nil)
    }
    
    func writePrimaryColor(_ color: UIColor) {
        if (dataModel.getValue(key: SlStandartData.primaryColorKey) as? UIColor != color) {
            slStandartPeripheral.writePrimaryColor(color)
            dataModel.setValue(key: SlStandartData.primaryColorKey, value: color)
            updateCell(for: primaryColorCell, with: .none)
        }
    }
    
    func writeLedState(state: Bool) {
        dataModel.setValue(key: SlStandartData.ledStateKey, value: state)
        slStandartPeripheral.writeLedState(state)
    }
    
    func writeLedBrightness(value: Int) {
        if (dataModel.getValue(key: SlStandartData.ledBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.ledBrightnessKey, value: value)
            slStandartPeripheral.writeLedBrightness(value)
        }
    }
    
    func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlStandartData.ledTimeoutKey, value: timeout)
        slStandartPeripheral.writeLedTimeout(Int(timeout))
    }
    
    func writeAnimationSpeed(speed: Int) {
        if (dataModel.getValue(key: SlStandartData.animationSpeedKey) as? Int != speed) {
            dataModel.setValue(key: SlStandartData.animationSpeedKey, value: speed)
            slStandartPeripheral.writeAnimationOnSpeed(speed)
        }
    }
    
    func writeTopTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: value)
            slStandartPeripheral.writeTopSensorTriggerDistance(value)
        }
    }
    
    func writeBotTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: value)
            slStandartPeripheral.writeBotSensorTriggerDistance(value)
        }
    }
    
    func writeTopTriggerLightness(value: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerLightnessKey, value: value)
        slStandartPeripheral.writeTopSensorLightness(value)
    }
    
    func writeBotTriggerLightness(value: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerLightnessKey, value: value)
        slStandartPeripheral.writeBotSensorLightness(value)
    }
    
    func writeStepsCount(count: Int) {
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
        slStandartPeripheral.writeStepsCount(count)
    }
    
    func writeStandbyState(state: Bool) {
        dataModel.setValue(key: SlStandartData.standbyStateKey, value: state)
        slStandartPeripheral.writeStandbyState(state)
    }
    
    func writeStandbyBrightness(value: Int) {
        if (dataModel.getValue(key: SlStandartData.standbyBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.standbyBrightnessKey, value: value)
            slStandartPeripheral.writeStandbyBrightness(value)
        }
    }
    
    func writeStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyTopCountKey, value: count)
        slStandartPeripheral.writeStandbyTopCount(count)
    }
    
    func writeStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyBotCountKey, value: count)
        slStandartPeripheral.writeStandbyBotCount(count)
    }
    
    private func initTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as! Int != 0
    }
    
    private func initBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as! Int != 0
    }
    
    private func initStepsCount(count: Int) {
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
    }
    
}

extension SlStandartViewModel: SlStandartPeripheralDelegate {
    
    func getLedType(type: PeripheralDataElement) {
        print("LED TYPE - \(type.name)")
        dataModel.setValue(key: SlStandartData.ledTypeKey, value: type)
    }
    
    func getLedAdaptiveBrightnessState(mode: PeripheralDataElement) {
        print("LED adaptive mode - \(mode.name)")
        dataModel.setValue(key: SlStandartData.ledAdaptiveModeKey, value: mode)
    }
    
    func getWorkMode(mode: Int) {
        print("GOT WORK MODE - \(mode)")
        dataModel.setValue(key: SlStandartData.stairsWorkMode, value: mode)
    }
    
    func getStepsCount(count: Int) {
        print("GET STEPS COUNT - \(count)")
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
        updateCell(for: stepsCountCell, with: .middle)
    }
    
    func getStandbyState(state: Bool) {
        dataModel.setValue(key: SlStandartData.standbyStateKey, value: state)
        updateCell(for: standbyStateCell, with: .middle)
    }
    
    func getStandbyBrightness(brightness: Int) {
        dataModel.setValue(key: SlStandartData.standbyBrightnessKey, value: brightness)
        updateCell(for: standbyBrightnessCell, with: .middle)
    }
    
    func getStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyTopCountKey, value: count)
        updateCell(for: standbyTopCountCell, with: .middle)
    }
    
    func getStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyBotCountKey, value: count)
        updateCell(for: standbyBotCountCell, with: .middle)
    }
    
    func getTopSensorTriggerLightness(lightness: Int) {
        print("TOP TRIGGER LIGHTNESS \(lightness)")
        dataModel.setValue(key: SlStandartData.topTriggerLightnessKey, value: lightness)
        
        updateCell(for: topTriggerLightnessCell, with: .middle)
    }
    
    func getBotSensorTriggerLightness(lightness: Int) {
        print("BOT TRIGGER LIGHTNESS \(lightness)")
        dataModel.setValue(key: SlStandartData.botTriggerLightnessKey, value: lightness)
        updateCell(for: botTriggerLightnessCell, with: .middle)
    }
    
    func getTopSensorCurrentLightness(lightness: Int) {
        print("TOP CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlStandartData.topCurrentLightnessKey, value: lightness)
        updateCell(for: topCurrentLightnessCell, with: .none)
    }
    
    func getBotSensorCurrentLightness(lightness: Int) {
        print("BOT CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlStandartData.botCurrentLightnessKey, value: lightness)
        updateCell(for: botCurrentLightnessCell, with: .none)
    }
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: SlStandartData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: SlStandartData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: SlStandartData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
        print("LED STATE - \(state)")
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlStandartData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
        print("LED BRIGHNTESS - \(brightness)")
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlStandartData.ledTimeoutKey, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
        print("LED TIMEOUT - \(timeout)")
    }
    
    func getAnimationMode(mode: PeripheralAnimations) {
        dataModel.setValue(key: SlStandartData.animationModeKey, value: mode)
        updateCell(for: animationModeCell, with: .middle)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: SlStandartData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    // Unused
    func getSecondaryColor(_ color: UIColor) { }
    func getAnimationOffSpeed(speed: Int) { }
    func getAnimationStep(step: Int) { }
    func getAnimationDirection(direction: PeripheralAnimationDirections) { }
    
}

extension SlStandartViewModel: PeripheralTableViewModelDataSourceAndDelegate {
    
    func readyTableViewModel() -> TableViewModel {
        return TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_led_section_header".localized,
                    footerText: "peripheral_sl_standart_led_section_footer".localized,
                    rows: [ledStateCell, ledBrightnessCell, ledTimeoutCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell])
            ], type: .ready)
    }
    
    func setupTableViewModel() -> TableViewModel? {
        return TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerLightnessCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell])
            ], type: .setup)
    }
    
    func settingsTableViewModel() -> TableViewModel? {
        return TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_sl_standart_steps_settings_section_header".localized,
                    footerText: "peripheral_sl_standart_steps_settings_section_footer".localized,
                    rows: [stepsCountCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_standby_section_header".localized,
                    footerText: "peripheral_sl_standart_standby_section_footer".localized,
                    rows: [standbyStateCell, standbyBrightnessCell, standbyTopCountCell, standbyBotCountCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_sensor_trigger_distance_section_header".localized,
                    footerText: "peripheral_sl_standart_sensor_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_sensor_trigger_lightness_section_header".localized,
                    footerText: "peripheral_sl_standart_sensor_trigger_lightness_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell]),
                SectionModel(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell]),
                SectionModel(
                    headerText: "ХУЕТА",
                    footerText: "СУЕТА",
                    rows: [topCurrentLightnessCell, botCurrentLightnessCell])
            ], type: .settings)
    }
    
}
