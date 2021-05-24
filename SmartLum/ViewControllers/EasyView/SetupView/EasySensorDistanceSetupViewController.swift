//
//  EasySetupSecondViewController.swift
//  SmartLum
//
//  Created by Tim on 03.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol EasySensorDistanceSetupDelegate {
    func sensorDistance(location: EasyData.sensorLocation, distance: Int)
}

class EasySensorDistanceSetupViewController: UIViewController,
                                             EasySetupDelegate {
    
    var delegate: EasySensorDistanceSetupDelegate?
    
    @IBOutlet private var outletCollectionAuto: [UILabel]!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSetupSlider: UISlider!
    @IBOutlet weak var distanceSetupSegmentedControl: UISegmentedControl!
    
    private var peripheral: EasySetupViewController?
    private var sensorLocation: EasyData.sensorLocation
    private let sensorName: [Int:String] = [0:"Bottom", 1:"Top"]
    
    enum SetupMethod {
        case manual
        case auto
    }
    
    var setupMethod: SetupMethod = .auto
    
    init(with sensorType: EasyData.sensorLocation, delegate: EasySetupViewController) {
        self.sensorLocation = sensorType
        self.peripheral = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral?.setupDelegate = self
        distanceSetupSlider.isHidden = true
        headerLabel.text = "Set \(sensorName[sensorLocation.rawValue] ?? "Unkown") sensor trigger distance"
    }
    
    @IBAction func onDistanceSelected(_ sender: UISlider) {
        if setupMethod == .manual {
            let step: Float = 10
            let roundedValue = round(sender.value / step) * step
            sender.value = roundedValue
            distanceLabel.text = String(roundedValue)
            delegate?.sensorDistance(location: sensorLocation, distance: Int(roundedValue) * 10)
        }
    }
    
    @IBAction func onSetupMethodSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setupMethod = .auto
            distanceSetupSlider.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            setupMethod = .manual
            distanceSetupSlider.isHidden = false
        }
    }
    
    func botSensorCurrentDistance(_ distance: Int) {
        if setupMethod == .auto {
            distanceLabel.text = String(distance)
            delegate?.sensorDistance(location: sensorLocation, distance: distance)
        }
    }
    
    func topSensorCurrentDistance(_ distance: Int) {
        if setupMethod == .auto {
            distanceLabel.text = String(distance)
            delegate?.sensorDistance(location: sensorLocation, distance: distance)
        }
    }

}
