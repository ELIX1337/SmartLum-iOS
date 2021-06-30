//
//  TorchereViewController.swift
//  SmartLum
//
//  Created by Tim on 11.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SLViewController: UIViewController {
    
    private var peripheral: BasePeripheral!
    private var firstPeripheral: FirstPeripheral!
    
    @IBOutlet weak var btnColor: UIButton!
    @IBOutlet weak var switchAnimation: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstPeripheral.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            firstPeripheral.disconnect()
        }
    }
    
    @IBAction func onColorButton(_ sender: Any) {
        firstPeripheral.setAnimationMode(1)
    }
    
    @IBAction func onAnimationSwitch(_ sender: UISwitch) {
        print("zero")
        if firstPeripheral.type == SecondPeripheral.self {
            sender.isOn ?
                (firstPeripheral as? SecondPeripheral)?.writePrimaryColor(UIColor.red)
                :
                (firstPeripheral as? SecondPeripheral)?.writePrimaryColor(UIColor.white)
            print("second")
        } else  {
            print("first")
            sender.isOn ?
                //firstPeripheral.writePrimaryColor(UIColor.red)
                firstPeripheral.setPrimaryColor(UIColor.red)
                :
                firstPeripheral.writePrimaryColor(UIColor.white)
        }
    }
    
    // MARK: - Implementation
    
    public func setPeripheral(_ peripheral: AdvertisedData) {
        if peripheral.type == FirstPeripheral.self {
            //self.peripheral = FirstPeripheral(peripheral.peripheral, peripheral.centralManager)
            self.firstPeripheral = FirstPeripheral(peripheral.peripheral, peripheral.centralManager)
        } else if peripheral.type == SecondPeripheral.self {
            self.peripheral = SecondPeripheral(peripheral.peripheral, peripheral.centralManager)
        } else {
            self.peripheral = BasePeripheral(peripheral.peripheral, peripheral.centralManager)
        }
        print("TYPE \(String(describing: peripheral.type))")
        title = peripheral.advertisedName
    }
    
}
