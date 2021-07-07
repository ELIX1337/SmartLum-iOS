//
//  PickerViewController.swift
//  SmartLum
//
//  Created by ELIX on 06.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class WheelPickerViewController: PopupPickerViewController {

    public var delegate: UIPickerViewDelegate?
    public var dataSource: UIPickerViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.frame = CGRect(x: 0,
                                     y: UIScreen.main.bounds.height - 300,
                                     width: UIScreen.main.bounds.width,
                                     height: 300)
        let pickerView = UIPickerView(frame: containerView.frame)
        self.view.addSubview(pickerView)
        pickerView.backgroundColor = UIColor.clear
        pickerView.delegate = self.delegate
        pickerView.dataSource = self.dataSource
    }
}


