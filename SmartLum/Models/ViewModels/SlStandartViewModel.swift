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
    var primaryColorCell:  PeripheralCell!
    // LED section
    var ledBrightnessCell: PeripheralCell!
    var ledTimeoutCell: PeripheralCell!
    // Animation section
    var animationModeCell: PeripheralCell!
    var animationSpeedCell: PeripheralCell!
    var animationDirectionCell: PeripheralCell!
    // Sensor section
    var topTriggerDistanceCell: PeripheralCell!
    var botTriggerDistanceCell: PeripheralCell!
    var topTriggerLightnessCell: PeripheralCell!
    var botTriggerLightnessCell: PeripheralCell!
    // Factory section
    var resetToFactoryCell: PeripheralCell!
    
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
                  _ selected: @escaping (PeripheralCell) -> Void) {
        super.init(withTableView, withPeripheral as! SlStandartPeripheral, delegate, selected)
        self.slStandartPeripheral.delegate = self
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
            initialValue: UIColor.white)
    }
    
    private func initLedSection() {
        ledBrightnessCell = .sliderCell(
            key: SlStandartData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: SlBaseData.ledBrightnessKey) as? Float ?? 0),
            minValue: Float(SlStandartData.ledMinBrightness),
            maxValue: Float(SlStandartData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false)
        ledTimeoutCell = .stepperCell(
            key: SlStandartData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.ledMinTimeout),
            maxValue: Double(SlStandartData.ledMaxTimeout))
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
            showValue: false)
        animationDirectionCell = .pickerCell(
            key: SlStandartData.animationDirectionKey,
            title: "peripheral_animation_direction_cell_title".localized,
            initialValue: "")
    }
    
    private func initSettingsSection() {
        topTriggerDistanceCell = .sliderCell(
            key: SlStandartData.topTriggerDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 0,
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        botTriggerDistanceCell = .sliderCell(
            key: SlStandartData.botTriggerDistanceKey,
            title: "peripheral_bot_sensor_cell_title".localized,
            initialValue: 0,
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        topTriggerLightnessCell = .sliderCell(
            key: SlStandartData.topLightnessDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        botTriggerLightnessCell = .sliderCell(
            key: SlStandartData.botLightnessDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true)
        resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized)
    }
    
    func writePrimaryColor(_ color: UIColor) {
        slStandartPeripheral.writePrimaryColor(color)
        dataModel.setValue(key: SlStandartData.primaryColorKey, value: color)
        reloadCell(for: primaryColorCell, with: .none)
    }
    
}

extension SlStandartViewModel: SlBasePeripheralDelegate {
    
    func getTopSensorTriggerDistance(distance: Int) {
        // TODO:
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        // TODO:
    }
    
    func getLedState(state: Bool) {
        // TODO:
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlStandartData.ledBrightnessKey, value: brightness)
        reloadCell(for: ledBrightnessCell, with: .middle)
        print("LED BRIGHNTESS - \(brightness)")
    }
    
    func getLedTimeout(timeout: Int) {
        // TODO:
    }
    
    func getAnimationMode(mode: PeripheralAnimations) {
        // TODO:
    }
    
    func getAnimationOnSpeed(speed: Int) {
        // TODO:
    }
    
    func getAnimationOffSpeed(speed: Int) {
        // TODO:
    }
    
    func getAnimationDirection(direction: PeripheralAnimationDirections) {
        // TODO:
    }
    
    func getAnimationStep(step: Int) {
        // TODO:
    }
    
}

extension SlStandartViewModel: PeripheralTableViewModelDataSourceAndDelegate {
    
    func callback(from cell: PeripheralCell, with value: Any?, in tableView: UITableView) {
        
    }
    
    func readyTableViewModel() -> PeripheralTableViewModel {
        return PeripheralTableViewModel(
            sections: [
                PeripheralSection(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell]),
                PeripheralSection(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [ledBrightnessCell, ledTimeoutCell]),
                PeripheralSection(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell, animationDirectionCell])
            ], type: .ready)
    }
    
    func setupTableViewModel() -> PeripheralTableViewModel? {
        return PeripheralTableViewModel(
            sections: [
                PeripheralSection(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerLightnessCell]),
                PeripheralSection(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell])
            ], type: .setup)
    }
    
    func settingsTableViewModel() -> PeripheralTableViewModel? {
        return PeripheralTableViewModel(
            sections: [
                PeripheralSection(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerLightnessCell]),
                PeripheralSection(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell]),
                PeripheralSection(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell])
            ], type: .settings)
    }
    
}
