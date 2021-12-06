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
        self.viewModel = FlClassicViewModel(tableView, peripheral, self) {
            self.onCellSelected(cell: $0)
        }
    }
    
    func onCellSelected(cell: CellModel) {
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
                pushPicker(FlClassicAnimations.allCases) {
                    mViewModel.writeAnimationMode(mode: $0)
                }
                break
            case mViewModel.animationDirectionCell:
                pushPicker(PeripheralAnimationDirections.allCases) {
                    mViewModel.writeAnimationDirection(direction: $0)
                }
                break
            default:
                return
            }
        }
    }
    
}
