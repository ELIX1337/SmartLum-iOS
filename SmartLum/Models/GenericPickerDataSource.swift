//
//  GenericPickerDataSource.swift
//  SmartLum
//
//  Created by ELIX on 02.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

struct GenericRow<T> {
    let type: T
    let title: String
    public init(type: T, title: String) {
        self.type = type
        self.title = title
    }
}

protocol GenericPickerDataSourceDelegate: AnyObject {
    func selected(item: Any)
}

/**
 The aim of this class is to use a set of enums as a pickerView data source, instead of creating multiple classes
 We use generics to populate this class.
 */
class GenericPickerDataSource<T>: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

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

    func setupPickerField<T>(withDataSource dataSource: GenericPickerDataSource<T>) {

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
