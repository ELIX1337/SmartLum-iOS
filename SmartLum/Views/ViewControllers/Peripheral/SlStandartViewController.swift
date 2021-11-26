//
//  SlStandartViewController.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class SlStandartViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = SlStandartViewModel(self.tableView, peripheral, self, onCellSelected(model:))
    }
    
    func onCellSelected(model: CellModel) {
        if let mViewModel = self.viewModel as? SlStandartViewModel {
            switch model {
            case mViewModel.primaryColorCell:
                pushColorPicker(model, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(PeripheralAnimations.allCases) { selection in
                    print("SELECTED - \(selection.name)")
                }
                break
            default:
                return
            }
            switch model.cellKey {
            case SlStandartData.ledTypeKey:
                pushPicker(PeripheralLedType.allCases) { type in
                    print("CELL TYPE - \(type.name)")
                }
                break
            case SlStandartData.ledAdaptiveModeKey:
                pushPicker(PeripheralLedAdaptiveMode.allCases) { mode in
                    print("ADAPTIVE MODE - \(mode.name)")
                }
                break
            default:
                return
            }
        }
    }
    
}

class SlStandartSetupViewController: PeripheralSetupViewController {
    
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}
