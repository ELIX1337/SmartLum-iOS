//
//  TorchereViewController.swift
//  SmartLum
//
//  Created by Tim on 11.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SLViewController: UIViewController, ColorPeripheralDelegate, AnimationPeripheralDelegate {
    
    func peripheralDidConnect() {
        //
    }
    
    func peripheralDidDisconnect() {
        //
    }
    
    func peripheralIsReady() {
        //
    }
    
    func peripheralFirmwareVersion(_ version: Int) {
        //
    }
    
    func peripheralOnDFUMode() {
        //
    }
    
    func getAnimationOffSpeed(speed: Int) {
        //
    }
    
    func getAnimationDirection(direction: Int) {
        //
    }
    
    func getAnimationStep(step: Int) {
        //
    }
    
    
    func getPrimaryColor(_ color: UIColor) {
        print("Delegate color")
    }
    
    func getSecondaryColor(_ color: UIColor) {
        print("Delegate color")
    }
    
    func getRandomColor(_ color: Bool) {
        print("Delegate color")
    }
    
    func getAnimationMode(mode: Int) {
        print("Delegate anim")
    }
    
    func getAnimationOnSpeed(speed: Int) {
        print("Delegate anim")
    }
    
    
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
        if peripheral.peripheralType == FirstPeripheral.self {
            self.firstPeripheral = FirstPeripheral(peripheral.peripheral, peripheral.centralManager)
            self.firstPeripheral.delegate = self
        } else if peripheral.peripheralType == SecondPeripheral.self {
            self.peripheral = SecondPeripheral(peripheral.peripheral, peripheral.centralManager)
        } else {
            self.peripheral = BasePeripheral(peripheral.peripheral, peripheral.centralManager)
        }
        print("TYPE \(String(describing: peripheral.peripheralType))")
        title = peripheral.advertisedName
    }
    
}
