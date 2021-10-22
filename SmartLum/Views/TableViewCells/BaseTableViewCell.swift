//
//  BaseTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 15.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

protocol BaseTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { get }
    func configure(title: String?, value: Any?)
    func additionalData(closure: () -> Void)
    func defaultInit()
    var returnValue: ((_ value: Any) -> Void)? { get set }
}

extension BaseTableViewCell {
    //var returnValue: ((_ value: Any) -> Void)? { get { returnValue } set { }}
    func additionalData(closure: () -> Void) { }
}

extension BaseTableViewCell where Self:SliderTableViewCell {
    func setSliderRange(minValue: Float, maxValue: Float) {
        self.slider.minimumValue = minValue
        self.slider.maximumValue = maxValue
    }
}

