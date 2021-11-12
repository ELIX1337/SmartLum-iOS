//
//  FlClassic.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class FlClassicViewModel: PeripheralViewModel {
        
    var peripheral: FlClassicPeripheral! {
        get { return (super.basePeripheral as! FlClassicPeripheral) }
    }
    
    var primaryColorCell:       CellModel!
    var secondaryColorCell:     CellModel!
    var randomColorCell:        CellModel!
    var animationModeCell:      CellModel!
    var animationSpeedCell:     CellModel!
    var animationDirectionCell: CellModel!
    var animationStepCell:      CellModel!
    
    // Public variables for using in viewController
    var primaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    var secondaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        peripheral.delegate = self
        tableViewDataSourceAndDelegate = self
        dataModel = FlClassicData.init(values: [:])
        initColorSection()
        initAnimationSection()
    }
    
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: FlClassicData.primaryColorKey,
            title: "peripheral_primary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.primaryColorKey) as? UIColor ?? UIColor.SLWhite,
            callback: { color in
                self.dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
                self.writePrimaryColor(color: color)
            })
        secondaryColorCell = .colorCell(
            key: FlClassicData.secondaryColorKey,
            title: "peripheral_secondary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor ?? UIColor.SLWhite,
            callback: { color in
                self.dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
                self.writeSecondaryColor(color: color)
            })
        randomColorCell = .switchCell(
            key: FlClassicData.randomColorKey,
            title: "peripheral_random_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.randomColorKey) as? Bool ?? false,
            callback: { self.writeRandomColor(state: $0) })
    }
    
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: FlClassicData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.animationModeKey) as? String ?? "")
        animationSpeedCell = .sliderCell(
            key: FlClassicData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: FlClassicData.animationSpeedKey) as? Int ?? 0),
            minValue: Float(FlClassicData.animationMinSpeed),
            maxValue: Float(FlClassicData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { speed in
                self.writeAnimationOnSpeed(speed: Int(speed))
                self.dataModel.setValue(key: FlClassicData.animationSpeedKey, value: Int(speed))
            })
        animationDirectionCell = .pickerCell(
            key: FlClassicData.animationDirectionKey,
            title: "peripheral_animation_direction_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.animationDirectionKey) as? String ?? "")
        animationStepCell = .stepperCell(
            key: FlClassicData.animationStepKey,
            title: "peripheral_animation_step_cell_title".localized,
            initialValue: Double(dataModel.getValue(key: FlClassicData.animationStepKey) as? Int ?? 0),
            minValue: Double(FlClassicData.animationMinStep),
            maxValue: Double(FlClassicData.animationMaxStep),
            callback: { self.writeAnimationStep(step: Int($0)) })
    }
    
    // Updating tableView depending selected animation
    private func updateCellsFor(animation: PeripheralAnimations) {
        switch animation {
        case .tetris:
            hideCell(rows: [animationStepCell], rowsSection: nil)
            break
        case .wave:
            hideCell(rows: [randomColorCell], rowsSection: nil)
            break
        case .transfusion:
            hideCell(rows: [animationStepCell, animationDirectionCell], rowsSection: nil)
            break
        case .rainbowTransfusion:
            hideCell(rows: [animationStepCell, animationDirectionCell], rowsSection: [primaryColorCell])
            break
        case .rainbow:
            hideCell(rows: [animationStepCell], rowsSection: [primaryColorCell])
            break
        case .static:
            hideCell(rows: [animationStepCell, animationSpeedCell, animationDirectionCell, secondaryColorCell, randomColorCell], rowsSection: nil)
            break
            
        }
    }
    
    // Public API
    public func writePrimaryColor(color: UIColor) {
        peripheral.writePrimaryColor(color)
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        reloadCell(for: primaryColorCell, with: .none)
    }
    
    public func writeSecondaryColor(color: UIColor) {
        peripheral.writeSecondaryColor(color)
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        reloadCell(for: secondaryColorCell, with: .none)
    }
    
    public func writeRandomColor(state: Bool) {
        peripheral.writeRandomColor(state)
        dataModel.setValue(key: FlClassicData.randomColorKey, value: state)
    }
    
    public func writeAnimationMode(mode: PeripheralAnimations) {
        peripheral.writeAnimationMode(mode)
        updateCellsFor(animation: mode)
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode)
        reloadCell(for: animationModeCell, with: .none)
    }
    
    public func writeAnimationDirection(direction: PeripheralAnimationDirections) {
        peripheral.writeAnimationDirection(direction)
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        reloadCell(for: animationDirectionCell, with: .none)
    }
    
    public func writeAnimationOnSpeed(speed: Int) {
        peripheral.writeAnimationOnSpeed(speed)
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
    }
    
    public func writeAnimationStep(step: Int) {
        peripheral.writeAnimationStep(step)
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
    }
    
}

// Data from peripheral
extension FlClassicViewModel: FlClassicPeripheralDelegate {
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        reloadCell(for: primaryColorCell, with: .middle)
    }
    
    func getSecondaryColor(_ color: UIColor) {
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        reloadCell(for: secondaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: FlClassicData.randomColorKey, value: state)
        reloadCell(for: randomColorCell, with: .middle)
    }
    
    func getAnimationMode(mode: PeripheralAnimations) {
        updateCellsFor(animation: mode)
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode)
        reloadCell(for: animationModeCell, with: .middle)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
        reloadCell(for: animationSpeedCell, with: .middle)
    }
        
    func getAnimationDirection(direction: PeripheralAnimationDirections) {
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        reloadCell(for: animationDirectionCell, with: .middle)
    }
    
    func getAnimationStep(step: Int) {
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        reloadCell(for: animationStepCell, with: .middle)
    }
    
    // Unused
    func getAnimationOffSpeed(speed: Int) { }

}

// PeripheraTableViewModel dataSource and delegate
extension FlClassicViewModel: PeripheralTableViewModelDataSourceAndDelegate {
    
    func readyTableViewModel() -> TableViewModel {
        return TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell, secondaryColorCell, randomColorCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell, animationDirectionCell, animationStepCell])
            ], type: .ready)
    }
    
    func setupTableViewModel() -> TableViewModel? {
        return nil
    }
    
    func settingsTableViewModel() -> TableViewModel? {
        return nil
    }
    
}
