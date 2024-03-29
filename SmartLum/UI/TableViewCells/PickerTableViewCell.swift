//
//  PickerTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 13.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static var nibName: String = "PickerTableViewCell"
    static let reuseIdentifier: String = "PickerCellID"
    
    var callback: ((Any) -> Void)?

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(title: String?, value: Any?) {
        self.titleLabel.text = title?.localized
        if let value = value as? String {
            self.valueLabel.text = value.localized
        }
    }

    func defaultInit() {
        print("Doing picker cell default init")
    }
    
}
