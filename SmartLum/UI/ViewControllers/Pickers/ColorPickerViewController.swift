//
//  ColorPickerViewController.swift
//  SmartLum
//
//  Created by Tim on 15.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import Colorful

class ColorPickerViewController: PopupPickerViewController {
    
    private var initColor: UIColor?
    private var indicator: UIView?
    private var sender: Any?
    private var onColorChange: ((UIColor, Any?) -> Void)!
    private lazy var colorPickerView = ColorPicker.init()
    
    override func viewDidLayoutSubviews() {
        self.containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        self.containerView.addSubview(colorPickerView)
        self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        self.colorPickerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.colorPickerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        self.colorPickerView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        self.colorPickerView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        self.colorPickerView.addTarget(self, action: #selector(self.onColorChanged(picker:)), for: .valueChanged)
        self.colorPickerView.set(color: initColor ?? UIColor.white, colorSpace: .sRGB)
        self.colorUI(colorPickerView.color)
    }
    
    public func configure(initColor: UIColor?,
                          colorIndicator: UIView?,
                          sender: Any,
                          onColorChange: @escaping (_ color: UIColor, _ sender: Any?) -> Void) {
        self.initColor = initColor
        self.indicator = colorIndicator
        self.sender = sender
        self.onColorChange = onColorChange
    }
    
    @objc func onColorChanged(picker: ColorPicker) {
        self.onColorChange(picker.color, sender)
        colorUI(picker.color)
    }
    
    private func colorUI(_ color: UIColor) {
        self.indicator?.backgroundColor = color
        containerView.backgroundColor = UIColor.dynamicColor(light: color.withAlphaComponent(0.5),
                                                             dark: color.withAlphaComponent(0.15))
    }
}

protocol ColorDelegate {
    func getColor(color: UIColor)
    func randomColor(enabled: Bool)
}
