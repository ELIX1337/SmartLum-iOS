//
//  UIColors.swift
//  SmartLum
//
//  Created by Tim on 04/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

extension UIColor {
    
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
    // Test for commit
    // Commit 3rd
    // Commit 4th
    
    // New branch feature
}
