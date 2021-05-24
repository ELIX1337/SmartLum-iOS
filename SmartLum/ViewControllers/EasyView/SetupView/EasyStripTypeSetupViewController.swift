//
//  EasyStripTypeSetupViewController.swift
//  SmartLum
//
//  Created by Tim on 03.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol EasyStripTypeSetupDelegate {
    func stripType(type: EasyData.stripType)
}

class EasyStripTypeSetupViewController: UIViewController {
    
    var delegate: EasyStripTypeSetupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onStripTypeSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            delegate?.stripType(type: EasyData.stripType.DEFAULT)
        } else if sender.selectedSegmentIndex == 1 {
            delegate?.stripType(type: EasyData.stripType.RGB)
        }
    }
}
