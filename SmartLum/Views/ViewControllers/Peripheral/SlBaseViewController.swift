//
//  SlBaseViewController.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class SlBaseViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    func viewModelInit(peripheral: BasePeripheral) {
        viewModel = SlBaseViewModel(tableView, peripheral, self, onCellSelected(cell:))
    }
    
    func onCellSelected(cell: CellModel) {
        switch cell.cellKey {
        case BasePeripheralData.errorKey:
            openPeripheralSettings()
            break
        case BasePeripheralData.factoryResetKey:
            showResetAlert()
            break
        default: break
        }
    }
    
}

class SlBaseSetupViewController: PeripheralSetupViewController {
    
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}
