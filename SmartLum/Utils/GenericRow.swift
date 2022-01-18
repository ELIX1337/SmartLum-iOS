//
//  GenericRow.swift
//  SmartLum
//
//  Created by ELIX on 02.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

/// Структура, используемая для работы с Picker'ами
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
