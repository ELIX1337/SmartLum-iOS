//
//  FlClassicViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class FlClassicViewController: PeripheralViewController, PeripheralViewControllerProtocol {
        
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = FlClassicViewModel(tableView, peripheral, self, onCellSelected(cell:))
    }
    
    func onCellSelected(cell: PeripheralCell) {
        if let mViewModel = viewModel as? FlClassicViewModel {
            switch cell {
            case mViewModel.primaryColorCell:
                pushColorPicker(cell, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color: color)
                }
                return
            case mViewModel.secondaryColorCell:
                pushColorPicker(cell, initColor: mViewModel.secondaryColor) { color, _ in
                    mViewModel.writeSecondaryColor(color: color)
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
