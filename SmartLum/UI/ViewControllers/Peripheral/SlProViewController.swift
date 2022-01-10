//
//  SlProViewController.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class SlProViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = SlProViewModel(self.tableView, peripheral, self) {
            self.onCellSelected(model:$0)
            guard let vm = self.viewModel as? SlProViewModel else { return }
            switch $0.cellKey {
            case SlProData.stairsWorkModeKey:
                self.pushPicker(PeripheralStairsWorkMode.allCases) { mode in
                    vm.writeStairsWorkMode(mode: mode)
                }
                break
            case SlProData.ledAdaptiveModeKey:
                self.pushPicker(PeripheralLedAdaptiveMode.allCases) { mode in
                    vm.writeLedAdaptiveBrightnessMode(mode: mode)
                }
                break
            case BasePeripheralData.factoryResetKey:
                self.showResetAlert()
                break
            default:
                break
            }
            
        }
    }
        
    func onCellSelected(model: CellModel) {
        if let mViewModel = self.viewModel as? SlProViewModel {
            switch model {
            case mViewModel.primaryColorCell:
                pushColorPicker(model, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(SlProAnimations.allCases) { selection in
                    mViewModel.writeAnimationMode(mode: selection)
                }
                break
            default:
                return
            }
        }
    }
    
}

class SlProSetupViewController: PeripheralSetupViewController {
    
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}

