//
//  EasySetupFirstViewController.swift
//  SmartLum
//
//  Created by Tim on 03.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol EasySensorDirectionSetupDelegate {
    func sensorDirection(location: EasyData.sensorLocation, direction: Int)
}

class EasySensorDirectionSetupViewController: UIViewController {
    
    var delegate: EasySensorDirectionSetupDelegate?

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var directionSegmentedControl: UISegmentedControl!
    private var sensorLocation: EasyData.sensorLocation
    private let sensorName: [Int:String] = [0:"Bottom", 1:"Top"]
    
    init(with sensorType: EasyData.sensorLocation) {
        sensorLocation = sensorType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = "Specify \(sensorName[sensorLocation.rawValue] ?? "Unkown") sensor location"
    }
    
    @IBAction func onDirectionSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate?.sensorDirection(location: sensorLocation, direction: 1)
            break
        case 1:
            delegate?.sensorDirection(location: sensorLocation, direction: 2)
            break
        case 2:
            delegate?.sensorDirection(location: sensorLocation, direction: 0)
            break
        default:
            print("Unknown selection")
        }
    }
        

}
