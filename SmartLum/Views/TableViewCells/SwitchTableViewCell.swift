//
//  SwitchTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 20.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static let reuseIdentifier: String = "SwitchCellID"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    var returnValue: ((Any) -> Void)?
    
    func configure(title: String?, value: Any?) {
        self.selectionStyle = .none
        self.titleLabel.text = title?.localized ?? ""
        if let enabled = value as? Bool {
            self.cellSwitch.setOn(enabled, animated: true)
        } else {
            print("Invalid value - \(String(describing: value))")
        }
    }
    
    func defaultInit() {
        self.cellSwitch.isOn = false
    }
    
    @IBAction func onSwitchValueChange(_ sender: UISwitch) {
        self.returnValue?(sender.isOn)
    }
}
