//
//  TorchereViewController.swift
//  SmartLum
//
//  Created by Tim on 11.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SLViewController: UIViewController {
    
    
    private var peripheral: SLPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            peripheral.disconnect()
        }
    }
    
    // MARK: - Implementation
    
    public func setPeripheral(_ peripheral: SLPeripheral) {
        if peripheral.type == FirstPeripheral.self {
            self.peripheral = FirstPeripheral(superPeripheral: peripheral)
        } else if peripheral.type == SecondPeripheral.self {
            self.peripheral = SecondPeripheral(superPeripheral: peripheral)
        } else {
            self.peripheral = peripheral
        }
        print("TYPE \(peripheral.type)")
        title = peripheral.advertisedName
        print("Services \(peripheral.services)")
    }
    
}
