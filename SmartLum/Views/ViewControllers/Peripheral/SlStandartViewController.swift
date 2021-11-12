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
        self.viewModel = SlStandartViewModel(self.tableView, peripheral, self, onCellSelected(cell:))
    }
    
    func onCellSelected(cell: PeripheralCell) {
        if let mViewModel = self.viewModel as? SlStandartViewModel {
            switch cell {
            case mViewModel.primaryColorCell:
                pushColorPicker(cell, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(PeripheralAnimations.allCases)
                break
            case mViewModel.animationDirectionCell:
                pushPicker(PeripheralAnimationDirections.allCases)
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
