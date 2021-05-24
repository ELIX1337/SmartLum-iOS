//
//  ColorPickerViewController.swift
//  SmartLum
//
//  Created by Tim on 15.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import Colorful

protocol ColorDelegate {
    func getColor(color: UIColor)
    func randomColor(enabled: Bool)
}

class ColorPickerViewController: UIViewController {

    @IBOutlet private weak var contentContainer : UIView!
    @IBOutlet private weak var randomColorLabel : UILabel!
    @IBOutlet private weak var randomColorSwitch: UISwitch!
    @IBOutlet private weak var colorPicker      : ColorPicker!
    
    private let colorSpace : HRColorSpace = .sRGB
    var pickerColor: UIColor?
    var randomColorSupported: Bool?
    var randomColorEnabled: Bool?
    var delegate   : ColorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        initColorPicker()
        initRandomColorMode(isSupported: randomColorSupported ?? false, isEnabled: randomColorEnabled ?? false)
        initViewController()
    }
    
    @IBAction func onRandomColorState(_ sender: UISwitch) {
        delegate?.randomColor(enabled: sender.isOn)
        initRandomColorMode(isSupported: true, isEnabled: sender.isOn)
    }
    
    @IBAction func onBackTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onColorChanged(picker: ColorPicker) {
        delegate?.getColor(color: picker.color)
        contentContainer.backgroundColor = UIColor.dynamicColor(light: picker.color.withAlphaComponent(0.5), dark: picker.color.withAlphaComponent(0.15))

    }
    
    private func initRandomColorMode(isSupported: Bool, isEnabled: Bool) {
        if isSupported {
            randomColorSwitch.isOn = isEnabled
            if isEnabled {
                colorPicker.isUserInteractionEnabled = false
                colorPicker.alpha = 0.5
            } else {
                colorPicker.isUserInteractionEnabled = true
                colorPicker.alpha = 1
            }
        } else {
            randomColorSwitch.isHidden = true
            randomColorLabel.isHidden = true
            print("Random noy supported")
        }

    }
    
    private func initColorPicker() {
        colorPicker.addTarget(self, action: #selector(self.onColorChanged(picker:)), for: .valueChanged)
        colorPicker.set(color: pickerColor ??
                UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: 1.0),
                        colorSpace: colorSpace)
    }
    
    private func initViewController() {
        randomColorLabel.text = "Random color".localized
        let blurEffect:UIBlurEffect!
        
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        } else {
            blurEffect = UIBlurEffect(style: .regular)
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        contentContainer.layer.cornerRadius = 20
        contentContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentContainer.layer.masksToBounds = true
        contentContainer.backgroundColor = pickerColor?.withAlphaComponent(0.15)
        contentContainer.insertSubview(blurEffectView, at: 0)
        colorPicker.backgroundColor = .clear
    }

}

extension ColorDelegate {
    func randomColor(enabled: Bool) {}
}

extension UIColor {

    func rgb() -> (red:Float, green:Float, blue:Float)? {
        var fRed   : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue  : CGFloat = 0
        var fAlpha : CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed   = Float(fRed)
            let iGreen = Float(fGreen)
            let iBlue  = Float(fBlue)
            return (red:iRed, green:iGreen, blue:iBlue)
        } else {
            return nil
        }
    }
}
