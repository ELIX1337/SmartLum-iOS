//
//  EasyInfoViewController.swift
//  SmartLum
//
//  Created by Tim on 20.02.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import iOSDFULibrary

protocol EasyInfoDelegate {
    func getStripType(type: EasyData.stripType)
    func resetDevice()
    func updateDeviceFirmware()
}

class EasyInfoViewController: UITableViewController,
                              UIDocumentPickerDelegate {
    
    var delegate: EasyInfoDelegate?
    
    @IBOutlet private weak var stripTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var stepsCountLabel: UILabel!
    @IBOutlet private weak var topSensorTriggerDistanceLabel: UILabel!
    @IBOutlet private weak var botSensorTriggerDistanceLabel: UILabel!
    @IBOutlet private weak var updateFirmwareButton: UIButton!
    @IBOutlet private weak var deviceResetButton: UIButton!
    
    var stripType:EasyData.stripType?
    var numberOfSteps:Int?
    var topSensorTriggerDistance:Int?
    var botSensorTriggerDistance:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let type = stripType {
            stripTypeSegmentedControl.selectedSegmentIndex = type.rawValue
        }
        
        if let count = numberOfSteps {
            stepsCountLabel.text = String(count)
        }
        
        if let topDistance = topSensorTriggerDistance {
            topSensorTriggerDistanceLabel.text = String(topDistance)
        }
        
        if let botDistance = botSensorTriggerDistance {
            botSensorTriggerDistanceLabel.text = String(botDistance)
        }
    }
    
    @IBAction func stripTypeControl(_ sender: UISegmentedControl) {
        delegate?.getStripType(type: EasyData.stripType.init(rawValue: sender.selectedSegmentIndex)!)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure to reset device?", message: "This action will reset device to factory settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { action in self.delegate?.resetDevice() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func selectFirmwareFile() {
//        if #available(iOS 14.0, *) {
//            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.pkware.zip-archive"], in: .import)
//            documentPicker.delegate = self
//            documentPicker.allowsMultipleSelection = false
//            present(documentPicker, animated: true, completion: nil)
//        } else {
//            // Fallback on earlier versions
//        }
        let alert = UIAlertController(title: "Updating device firmware", message: "This action starts update device firmware", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in self.delegate?.updateDeviceFirmware() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}
