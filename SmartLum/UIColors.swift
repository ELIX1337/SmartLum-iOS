//
//  UIColors.swift
//  SmartLum
//
//  Created by Tim on 04/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

extension UIColor {
    
    func toData() -> Data {
        let packet: [UInt8] = [UInt8(self.rgb()!.red   * 255),
                               UInt8(self.rgb()!.green * 255),
                               UInt8(self.rgb()!.blue  * 255)]
        return Data(bytes: packet, count: packet.count)
        
    }
    
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
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .light ? light : dark
            }
        } else {
            return light
        }
    }
    
    static let SLYellow = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.2509803922, alpha: 1)
    static let SLBlue = #colorLiteral(red: 0.1529411765, green: 0.1960784314, blue: 0.2392156863, alpha: 1)
    static let SLDarkBlue = #colorLiteral(red: 0.1137254902, green: 0.1450980392, blue: 0.1764705882, alpha: 1)
    static let SLRed = #colorLiteral(red: 0.9567440152, green: 0.2853084803, blue: 0.3770255744, alpha: 1)
    static let SLWhite = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let SLTest = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.2509803922, alpha: 1)
}

extension Bool {
    func toData() -> Data {
        var value = self ? Data([0x1]) : Data([0x0])
        return Data(bytes: &value, count: value.count)
    }
}

extension Int {
    func toData() -> Data {
        var value = UInt8(self)
        return Data(bytes: &value, count: 1)
    }
}
