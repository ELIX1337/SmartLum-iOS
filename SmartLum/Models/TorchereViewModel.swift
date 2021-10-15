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
    override var basePeripheral: BasePeripheral {
        get {
            return self.torcherePeripheral
        }
        set {
            if let newPeripheral = newValue as? TorcherePeripheral {
                torcherePeripheral = newPeripheral
            }
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ baseDelegate: BasePeripheralDelegate,
                  _ selected: @escaping (PeripheralRow) -> Void) {
        super.init(withTableView, withPeripheral, baseDelegate, selected)
        self.torcherePeripheral = TorcherePeripheral.init(withPeripheral.peripheral, withPeripheral.centralManager)
        self.basePeripheral = withPeripheral
        self.tableView = withTableView
        self.selection = selected
        self.torcherePeripheral.delegate = self
        self.basePeripheral.baseDelegate = baseDelegate
        self.dataModel.animationOnSpeed.minValue = 0
        self.dataModel.animationOnSpeed.maxValue = 30
        self.dataModel.animationStep.minValue = 0
        self.dataModel.animationStep.maxValue = 10
        self.tableViewModel = PeripheralTableViewModel.init(sections: [PeripheralSection.init(headerText: "Color",
                                                                                              footerText: "Choose and handle colors",
                                                                                              rows: [.primaryColor,
                                                                                                     .secondaryColor,
                                                                                                     .randomColor]),
                                                                       PeripheralSection.init(headerText: "Animation",
                                                                                              footerText: "Handle animation",
                                                                                              rows: [.animationMode,
                                                                                                     .animationOnSpeed,
                                                                                                     .animationDirection,
                                                                                                     .animationStep])])
    }
    
    override func cellCallback(fromRow: PeripheralRow, withValue: Any?) {
        switch fromRow {
        case .animationOnSpeed:
            print("Speed - \(String(describing: withValue))")
            if let value = withValue as? Float {
                torcherePeripheral.writeAnimationOnSpeed(Int(value))
                dataModel.animationOnSpeed.value = Int(value)
            }
            break
        case .randomColor:
            print("Random color - \(String(describing: withValue))")
            if let value = withValue as? Bool {
                torcherePeripheral.writeRandomColor(value)
                dataModel.randomColor = value
                value ? hideRows(rows: [.primaryColor, .secondaryColor]) : showRows(rows: [.primaryColor, .secondaryColor])
            }
            break
        case .animationStep:
            print("Animation step - \(String(describing: withValue))")
            if let value = withValue as? Int {
                torcherePeripheral.writeAnimationStep(value)
                dataModel.animationStep.value = value
            }
            break
        default:
            print("Default")
        }
    }
    
    private func updateCellsFor(animation: PeripheralAnimations) {
        tableView.beginUpdates()
        tableView.performBatchUpdates({
            showRows(rows: nil)
            showSections(of: nil)
            reloadCell(for: .animationMode, with: .none)
            switch animation {
            case .tetris:
                hideRows(rows: [.animationStep])
                break
            case .wave:
                hideRows(rows: [.randomColor])
                break
            case .transfusion:
                hideRows(rows: [.animationStep, .animationDirection])
                break
            case .rainbowTransfusion:
                hideRows(rows: [.animationStep, .animationDirection])
                hideSections(of: [.primaryColor])
                break
            case .rainbow:
                hideRows(rows: [.animationStep])
                hideSections(of: [.primaryColor])
                break
            case .static:
                hideRows(rows: [.animationStep, .animationOnSpeed, .animationDirection, .secondaryColor, .randomColor])
                break
            }
        }, completion: nil)
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    public func writePrimaryColor(color: UIColor) {
        torcherePeripheral.writePrimaryColor(color)
        dataModel.primaryColor = color
        reloadCell(for: .primaryColor, with: .none)
    }
    
    public func writeSecondaryColor(color: UIColor) {
        torcherePeripheral.writeSecondaryColor(color)
        dataModel.secondaryColor = color
        reloadCell(for: .secondaryColor, with: .none)
    }
    
//    public func writeRandomColorMode(state: Bool) {
//        torcherePeripheral.writeRandomColor(state)
//        dataModel.randomColor = state
//        reloadCell(for: .randomColor, with: .fade)
//    }
    
    public func writeAnimationMode(mode: PeripheralAnimations) {
        torcherePeripheral.writeAnimationMode(mode)
        dataModel.animationMode = mode
        updateCellsFor(animation: mode)
    }
    
    public func writeAnimationDirection(direction: PeripheralAnimationDirections) {
        torcherePeripheral.writeAnimationDirection(direction)
        dataModel.animationDirection = direction
        reloadCell(for: .animationDirection, with: .none)
    }
    
    public func writeAnimationOnSpeed(speed: Int) {
        torcherePeripheral.writeAnimationOnSpeed(speed)
        dataModel.animationOnSpeed.value = speed
    }
    
    public func writeAnimationOffSpeed(speed: Int) {
        torcherePeripheral.writeAnimationOffSpeed(speed)
        dataModel.animationOffSpeed.value = speed
    }
    
    public func writeAnimationStep(step: Int) {
        torcherePeripheral.writeAnimationStep(step)
        dataModel.animationStep.value = step
    }
    
}

extension TorchereViewModel: TorcherePeripheralDelegate {
 
    func getPrimaryColor(_ color: UIColor) {
        dataModel.primaryColor = color
        reloadCell(for: .primaryColor, with: .middle)
    }
    
    func getSecondaryColor(_ color: UIColor) {
        dataModel.secondaryColor = color
        reloadCell(for: .secondaryColor, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.randomColor = state
        reloadCell(for: .randomColor, with: .middle)
    }
    
    func getAnimationMode(mode: PeripheralAnimations) {
        dataModel.animationMode = mode
        updateCellsFor(animation: mode)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.animationOnSpeed.value = speed
        reloadCell(for: .animationOnSpeed, with: .middle)
    }
    
    func getAnimationOffSpeed(speed: Int) {
        dataModel.animationOffSpeed.value = speed
    }
    
    func getAnimationDirection(direction: PeripheralAnimationDirections) {
        dataModel.animationDirection = direction
        reloadCell(for: .animationDirection, with: .middle)
    }
    
    func getAnimationStep(step: Int) {
        dataModel.animationStep.value = step
        reloadCell(for: .animationStep, with: .middle)
    }
}
