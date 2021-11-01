//
//  ColorTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 22.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class ColorTableViewCell: UITableViewCell, BaseTableViewCell {
    var returnValue: ((Any) -> Void)?

    static let reuseIdentifier: String = "ColorCellID"

    func configure(title: String?, value: Any?) {
        self.textLabel?.text = title?.localized
        self.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        if let value = value as? UIColor {
            self.backgroundColor = UIColor.dynamicColor(
                light: value.withAlphaComponent(0.8),
                dark: value.withAlphaComponent(0.6))
        }
    }

    func defaultInit() {
        print("Doing picker cell default init")
    }
    
}
