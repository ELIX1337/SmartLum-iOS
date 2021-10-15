//
//  SlBaseViewModel.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlBaseViewModel: PeripheralViewModel {
    
    var slBasePeripheral: SlBasePeripheral!
    override var basePeripheral: BasePeripheral {
        get {
            return self.slBasePeripheral
        }
        set {
            if let newPeripheral = newValue as? SlBasePeripheral {
                slBasePeripheral = newPeripheral
            }
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ baseDelegate: BasePeripheralDelegate,
                  _ selected: @escaping (PeripheralRow) -> Void) {
        super.init(withTableView, withPeripheral, baseDelegate, selected)
        self.slBasePeripheral = SlBasePeripheral.init(withPeripheral.peripheral, withPeripheral.centralManager)
        self.basePeripheral = withPeripheral
        self.tableView = withTableView
        self.selection = selected
        self.slBasePeripheral.delegate = self
        self.basePeripheral.baseDelegate = baseDelegate
        self.dataModel.animationOnSpeed.minValue = 1
        self.dataModel.animationOnSpeed.maxValue = 100
        self.dataModel.ledBrightness.minValue = 0
        self.dataModel.ledBrightness.maxValue = 100
        self.tableViewModel = PeripheralTableViewModel.init(sections: [PeripheralSection.init(headerText: "LED",
                                                                                              footerText: "LED setup",
                                                                                              rows: [.ledState,
                                                                                                     .ledBrightness,
                                                                                                     .animationOnSpeed,
                                                                                                     .ledTimeout])])
    }
    
    override func cellCallback(fromRow: PeripheralRow, withValue: Any?) {
        switch fromRow {
        case .ledState:
            print("Led state - \(String(describing: withValue))")
            if let value = withValue as? Bool {
                slBasePeripheral.writeLedState(value)
                dataModel.ledState = value
            }
            break
        case .ledBrightness:
            print("Led brightness - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeLedBrightness(Int(value))
                dataModel.ledBrightness.value = Int(value)
            }
            break
        case .animationOnSpeed:
            print("Animation speed - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeAnimationOnSpeed(Int(value))
                //dataModel.animationOnSpeed = Int(value)
                dataModel.animationOnSpeed.value = Int(value)
            }
        case .ledTimeout:
            print("Led timeout - \(String(describing: withValue))")
            if let value = withValue as? Int {
                slBasePeripheral.writeLedTimeout(value)
                dataModel.ledTimeout.value = value
            }
        case .topSensorTriggerDistance:
            print("Top trigger - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeTopSensorTriggerDistance(Int(value))
                dataModel.topSensorTriggerDistance.value = Int(value)
            }
            break
        case .botSensorTriggerDistance:
            print("Bot trigger - \(String(describing: withValue))")
            if let value = withValue as? Float {
                slBasePeripheral.writeBotSensorTriggerDistance(Int(value))
                dataModel.botSensorTriggerDistance.value = Int(value)
            }
            break
        default:
            print("Default")
        }
    }
    
    public func writeTopSensorTriggerDistance(distance: Int) {
        slBasePeripheral.writeTopSensorTriggerDistance(distance)
        dataModel.topSensorTriggerDistance.value = distance
        reloadCell(for: .topSensorTriggerDistance, with: .none)
    }
    
    public func writeBotSensorTriggerDistance(distance: Int) {
        slBasePeripheral.writeBotSensorTriggerDistance(distance)
        dataModel.botSensorTriggerDistance.value = distance
        reloadCell(for: .botSensorTriggerDistance, with: .none)
    }
    
}

extension SlBaseViewModel: SlBasePeripheralDelegate {
    
    func getAnimationOnSpeed(speed: Int) {
        //dataModel.animationOnSpeed = speed
        dataModel.animationOnSpeed.value = speed
        reloadCell(for: .animationOnSpeed, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.ledBrightness.value = brightness
        reloadCell(for: .ledBrightness, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.ledTimeout.value = timeout
        reloadCell(for: .ledTimeout, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.ledState = state
        reloadCell(for: .ledState, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.topSensorTriggerDistance.value = distance
        reloadCell(for: .topSensorTriggerDistance, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.botSensorTriggerDistance.value = distance
        reloadCell(for: .botSensorTriggerDistance, with: .middle)
    }
    
    // Unused
    func getAnimationMode(mode: PeripheralAnimations) { }
    
    func getAnimationOffSpeed(speed: Int) { }
    
    func getAnimationDirection(direction: PeripheralAnimationDirections) { }
    
    func getAnimationStep(step: Int) { }
    
}

