//
//  EasySetupViewController.swift
//  SmartLum
//
//  Created by Tim on 02.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol EasySetupDelegate {
    func botSensorCurrentDistance(_ distance: Int)
    func topSensorCurrentDistance(_ distance: Int)
}

class EasySetupViewController: UIViewController,
                               EasySensorDirectionSetupDelegate,
                               EasySensorDistanceSetupDelegate,
                               EasyStripTypeSetupDelegate,
                               EasyExtendedDelegate {
    
    private var botSensorLocationViewController: EasySensorDirectionSetupViewController?
    private var topSensorLocationViewController: EasySensorDirectionSetupViewController?
    private var botSensorDistanceViewController: EasySensorDistanceSetupViewController?
    private var topSensorDistanceViewController: EasySensorDistanceSetupViewController?
    private var stripTypeSetupViewController: EasyStripTypeSetupViewController?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nextButton: UIButton!
    private var viewControllers: [Int:UIViewController]?
    private var currentViewControllerIndex = 1
    public var peripheral: EasyPeripheral?
    public var setupDelegate: EasySetupDelegate?
    private var sender: Timer?
    private var counter = 0;
    private var lastConfig: (register: Int, value: Int)?
    private var successWrite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        botSensorLocationViewController = EasySensorDirectionSetupViewController(with: EasyData.sensorLocation.bot)
        topSensorLocationViewController = EasySensorDirectionSetupViewController(with: EasyData.sensorLocation.top)
        botSensorDistanceViewController = EasySensorDistanceSetupViewController(with: EasyData.sensorLocation.bot, delegate: self)
        topSensorDistanceViewController = EasySensorDistanceSetupViewController(with: EasyData.sensorLocation.top, delegate: self)
        stripTypeSetupViewController = EasyStripTypeSetupViewController()
        
        botSensorLocationViewController?.delegate = self
        topSensorLocationViewController?.delegate = self
        botSensorDistanceViewController?.delegate = self
        topSensorDistanceViewController?.delegate = self
        stripTypeSetupViewController?.delegate    = self
        
        viewControllers = [1: botSensorLocationViewController!,
                           2: topSensorLocationViewController!,
                           3: botSensorDistanceViewController!,
                           4: topSensorDistanceViewController!,
                           5: stripTypeSetupViewController!]
        add(viewController: currentViewControllerIndex)
    }
    
    public func setPeripheral(_ peripheral: EasyPeripheral) {
        self.peripheral = peripheral
        self.peripheral?.extendedDelegate = self
    }
    
    @IBAction func onConfirmButtonTapped(_ sender: Any) {
        if let config = lastConfig {
            sendConfig(register: UInt8(config.register), value: config.value)
        }
    }
    
    private func sendConfig(register: UInt8, value: Int) {
        sender = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if self.successWrite {
                timer.invalidate()
                self.counter = 0
                self.pushNextView(self.currentViewControllerIndex)
            } else {
                self.counter += 1
                self.peripheral?.setCustomData(for: register, with: value)
                print("Setting register: \(register) with value \(value)")
                if self.counter == 20 {
                    self.counter = 0
                    timer.invalidate()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func pushNextView(_ index: Int) {
        remove(viewController: index)
        add(viewController: index + 1)
        currentViewControllerIndex += 1
        successWrite = false
    }
    
    private func add(viewController index: Int) {
        if let viewController = viewControllers![index] {
            addChild(viewController)
            UIView.transition(with: self.container, duration: 0.2, options: .transitionFlipFromRight, animations: {
                self.container.addSubview(viewController.view)
            }, completion: nil)
            
            viewController.view.frame = CGRect(
                x: 0,
                y: 0,
                width: self.container.frame.width,
                height: self.container.frame.height
            )
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.didMove(toParent: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func remove(viewController index: Int) {
        if let viewController = viewControllers![index] {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
    
    // MARK: - Child views delegate
    
    func sensorDirection(location: EasyData.sensorLocation, direction: Int) {
        if location == EasyData.sensorLocation.bot {
            lastConfig = (Sratocol.Device.Register.BOT_SENS_DIRECTION, direction)
            print("Selected bot sensor direction - \(direction)")
        } else if location == EasyData.sensorLocation.top {
            lastConfig = (Sratocol.Device.Register.TOP_SENS_DIRECTION, direction)
            print("Selected top sensor direction - \(direction)")
        }
    }
    
    func sensorDistance(location: EasyData.sensorLocation, distance: Int) {
        if !sender!.isValid {
            if location == EasyData.sensorLocation.bot {
                lastConfig = (Sratocol.Device.Register.BOT_SENS_TRIGGER_DISTANCE, distance)
                print("Selected bot sensor trigger distance - \(distance)")
            } else if location == EasyData.sensorLocation.top {
                lastConfig = (Sratocol.Device.Register.TOP_SENS_TRIGGER_DISTANCE, distance)
                print("Selected top sensor trigger distance - \(distance)")
            }
        }
    }
    
    func stripType(type: EasyData.stripType) {
        lastConfig = (Sratocol.Device.Register.STRIP_TYPE, type.rawValue)
        print("Selected strip type - \(type)")
    }
    
    // MARK: - Easy extended delegate
    // Checking written data
    
    func peripheralBotSensorDirection(_ direction: Int) {
        print("GOT BOT SENS DIRECTION \(direction)")
        if direction == lastConfig?.value {
            successWrite = true
        }
    }
    
    func peripheralTopSensorDirection(_ direction: Int) {
        print("GOT TOP SENS DIRECTION \(direction)")
        if direction == lastConfig?.value {
            successWrite = true
        }
    }
    
    func peripheralBotSensorCurrentDistance(_ distance: Int) {
        setupDelegate?.botSensorCurrentDistance(distance)
    }
    
    func peripheralTopSensorCurrentDistance(_ distance: Int) {
        setupDelegate?.topSensorCurrentDistance(distance)
    }
    
    func peripheralBotSensorTriggerDistance(_ distance: Int) {
        print("CONFIRMING BOT TRIGGER DISTANCE \(distance) - \(String(describing: lastConfig?.value))")
        if distance == lastConfig?.value {
            successWrite = true
        }
    }
    
    func peripheralTopSensorTriggerDistance(_ distance: Int) {
        print("CONFIRMING TOP TRIGGER DISTANCE \(distance) - \(String(describing: lastConfig?.value))")
        if distance == lastConfig?.value {
            successWrite = true
        }
    }
    
    func peripheralStripType(_ type: EasyData.stripType) {
        if type.rawValue == lastConfig?.value {
            successWrite = true
        }
    }
    
}
