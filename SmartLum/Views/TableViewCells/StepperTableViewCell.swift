//
//  StepperTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 14.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class StepperTableViewCell: UITableViewCell , BaseTableViewCell {
    
    static let reuseIdentifier: String = "StepperCellID"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    var callback: ((Any) -> Void)?
    
    func configure(title: String?, value: Any?) {
        self.selectionStyle = .none
        self.titleLabel.text = title?.localized
        self.valueLabel.text = String(describing: value as? Int ?? 0)
        if let value = value as? Int {
            self.stepper.value = Double(value)
            print("init stepper value with - \(value)")
        }
    }
    
    func defaultInit() {
        self.selectionStyle = .none
        print("Doing stepper cell default init")
    }
    
    @IBAction func onStepperValueChange(_ sender: UIStepper) {
        callback?(sender.value)
        valueLabel.text = String(Int(sender.value))
    }
    
}
