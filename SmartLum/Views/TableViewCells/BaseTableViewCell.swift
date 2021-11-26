//
//  BaseTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 15.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

protocol BaseTableViewCell: UITableViewCell {
    static var nibName: String { get }
    static var reuseIdentifier: String { get }
    func configure(title: String?, value: Any?)
    var callback: ((_ value: Any) -> Void)? { get set }
    func didSelect()
}

extension BaseTableViewCell {
    func didSelect() { }
//    var callback: (_ value: Any) -> Void {
//        get { return { _ in } }
//        set(newValue)
//    }

}


