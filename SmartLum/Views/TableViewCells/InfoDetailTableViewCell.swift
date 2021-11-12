//
//  InfoDetailTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 25.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class InfoDetailTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static var reuseIdentifier: String = "ErrorDetailCellID"
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var callback: ((Any) -> Void)?
        
    func configure(title: String?, value: Any?) {
    }
    
    @objc func openPeripheralSettings() {
        self.descriptionLabel.isHidden.toggle()
    }
    
}
