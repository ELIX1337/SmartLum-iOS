//
//  NewTorchereViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class TorchereViewModel: PeripheralViewModel {
    
    var torcherePeripheral: TorcherePeripheral!
    
    var primaryColorCell:       PeripheralCell!
    var secondaryColorCell:     PeripheralCell!
    var randomColorCell:        PeripheralCell!
    var animationModeCell:      PeripheralCell!
    var animationSpeedCell:     PeripheralCell!
    var animationDirectionCell: PeripheralCell!
    var animationStepCell:      PeripheralCell!
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (PeripheralCell) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        self.torcherePeripheral = TorcherePeripheral.init(withPeripheral.peripheral, withPeripheral.centralManager)
        self.basePeripheral = withPeripheral
        self.tableView = withTableView
        self.selection = selected
        self.torcherePeripheral.delegate = self
        self.dataModel = FlClassicData.init(values: [:])
        self.primaryColorCell = .colorCell(
            key: FlClassicData.primaryColorKey,
            title: "peripheral_primary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.primaryColorKey) as? UIColor ?? UIColor.SLWhite)
        self.secondaryColorCell = .colorCell(
            key: FlClassicData.secondaryColorKey,
            title: "peripheral_secondary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor ?? UIColor.SLWhite)
        self.randomColorCell = .switchCell(
            key: FlClassicData.randomColorKey,
            title: "peripheral_random_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.randomColorKey) as? Bool ?? false)
        self.animationModeCell = .pickerCell(
            key: FlClassicData.animationModeKey,
            title: "periphetal_animation_mode_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.animationModeKey) as? String ?? "")
        self.animationSpeedCell = .sliderCell(
            key: FlClassicData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: FlClassicData.animationSpeedKey) as? Int ?? 0),
            minValue: Float(FlClassicData.animationMinSpeed),
            maxValue: Float(FlClassicData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false)
        self.animationDirectionCell = .pickerCell(
            key: FlClassicData.animationDirectionKey,
            title: "peripheral_animation_direction_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.animationDirectionKey) as? String ?? "")
        self.animationStepCell = .stepperCell(
            key: FlClassicData.animationStepKey,
            title: "peripheral_animation_step_cell_title".localized,
            initialValue: Double(dataModel.getValue(key: FlClassicData.animationStepKey) as? Int ?? 0),
            minValue: Double(FlClassicData.animationMinStep),
            maxValue: Double(FlClassicData.animationMaxStep))
        self.peripheralReadyTableViewModel = PeripheralTableViewModel(
            sections: [
                PeripheralSection(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell, secondaryColorCell, randomColorCell]),
                PeripheralSection(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell, animationDirectionCell, animationStepCell])
            ])
    }
    
    override func cellDataCallback(fromRow: PeripheralCell, withValue: Any?) {
        super.cellDataCallback(fromRow: fromRow, withValue: withValue)
        switch fromRow {
        case animationSpeedCell:
            print("Speed - \(String(describing: withValue))")
            if let value = withValue as? Float {
                torcherePeripheral.writeAnimationOnSpeed(Int(value))
                dataModel.setValue(key: FlClassicData.animationSpeedKey, value: value)
            }
            break
        case randomColorCell:
            print("Random color - \(String(describing: withValue))")
            if let value = withValue as? Bool {
                torcherePeripheral.writeRandomColor(value)
                dataModel.setValue(key: FlClassicData.randomColorKey, value: value)
            }
            break
        case animationStepCell:
            print("Animation step - \(String(describing: withValue))")
            if let value = withValue as? Int {
                torcherePeripheral.writeAnimationStep(value)
                dataModel.setValue(key: FlClassicData.animationStepKey, value: value)
            }
            break
        default:
            print("Default")
        }
    }
    
    private func updateCellsFor(animation: PeripheralAnimations) {
       // if let value = dataModel.getValue(key: FlClassicData.animationModeKey) as? PeripheralAnimations {
           // if (value != animation) {
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
                //}
            //}
        }
    }
    
    public func writePrimaryColor(color: UIColor) {
        torcherePeripheral.writePrimaryColor(color)
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        reloadCell(for: primaryColorCell, with: .none)
    }
    
    public func writeSecondaryColor(color: UIColor) {
        torcherePeripheral.writeSecondaryColor(color)
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        reloadCell(for: secondaryColorCell, with: .none)
    }
    
    public func writeAnimationMode(mode: PeripheralAnimations) {
        torcherePeripheral.writeAnimationMode(mode)
        updateCellsFor(animation: mode)
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode)
        reloadCell(for: animationModeCell, with: .none)
    }
    
    public func writeAnimationDirection(direction: PeripheralAnimationDirections) {
        torcherePeripheral.writeAnimationDirection(direction)
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        reloadCell(for: animationDirectionCell, with: .none)
    }
    
    public func writeAnimationOnSpeed(speed: Int) {
        torcherePeripheral.writeAnimationOnSpeed(speed)
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
    }
    
    public func writeAnimationStep(step: Int) {
        torcherePeripheral.writeAnimationStep(step)
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
    }
    
}

extension TorchereViewModel: TorcherePeripheralDelegate {
    
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
    
    func getAnimationOffSpeed(speed: Int) { }
    
    func getAnimationDirection(direction: PeripheralAnimationDirections) {
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        reloadCell(for: animationDirectionCell, with: .middle)
    }
    
    func getAnimationStep(step: Int) {
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        reloadCell(for: animationStepCell, with: .middle)
    }
}
