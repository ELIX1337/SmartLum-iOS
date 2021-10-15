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
        self.viewModel = SlBaseViewModel(self.tableView, peripheral,
                                           self,
                                           { _ in Void.self })
    }
    
}
