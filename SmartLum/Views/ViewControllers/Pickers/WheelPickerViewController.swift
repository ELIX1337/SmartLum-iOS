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

class WheelPickerViewDataSource<T>: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    public var originalItems: [T]
    public var items: [GenericRow<T>]
    public var selected: (T) -> Void

    public init(withItems originalItems: [T], withRowTitle generateRowTitle: (T) -> String, didSelect selected: @escaping (T) -> Void) {
        self.originalItems = originalItems
        self.selected = selected

        self.items = originalItems.map {
            GenericRow<T>(type: $0, title: generateRowTitle($0))
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selected(items[row].type)
    }
}

extension UITextField {

    func setupPickerField<T>(withDataSource dataSource: WheelPickerViewDataSource<T>) {

        let pickerView = UIPickerView()
        self.inputView = pickerView
        self.addDoneToolbar()

        pickerView.delegate = dataSource
        pickerView.dataSource = dataSource
    }

    func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil) {

        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.tintColor = UIColor.blue

        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc private func doneButtonTapped() { self.resignFirstResponder() }
}


