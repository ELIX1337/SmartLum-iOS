//
//  SlStandartViewController.swift
//  SmartLum
//
//  Created by ELIX on 10.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class SlStandartViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = SlStandartViewModel(self.tableView, peripheral, self) {
            self.onCellSelected(model:$0)
            guard let vm = self.viewModel as? SlProViewModel else { return }
            switch $0.cellKey {
            case StairsControllerData.stairsWorkModeKey:
                self.pushPicker(PeripheralStairsWorkMode.allCases) { mode in
                    vm.writeStairsWorkMode(mode: mode)
                }
                break
            case StairsControllerData.ledAdaptiveModeKey:
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
        if let mViewModel = self.viewModel as? SlStandartViewModel {
            switch model {
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

class SlStandartSetupViewController: PeripheralSetupViewController {
    
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}

