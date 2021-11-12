//
//  InfoTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 25.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static var reuseIdentifier: String = "ErrorCellID"
    
    func configure(title: String?, value: Any?) { }
    
    func defaultInit() { }
    
    var callback: ((Any) -> Void)?
    
}
