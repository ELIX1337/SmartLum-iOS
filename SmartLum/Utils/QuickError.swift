//
//  QuickError.swift
//  Tim Yumalin
//
//  Created by Tim on 25.02.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation

/// ВНИМАНИЕ: Этот код использовался при тестировании DFU. В продакшене он не применяется.
/// Используется в DocumentPicker'е
protocol ReadableError: Error {
    var title: String { get }
    var readableMessage: String { get }
}

extension ReadableError {
    var title: String {
        return "Error"
    }
}

struct QuickError: ReadableError {
    let readableMessage: String
    
    init(message: String) {
        readableMessage = message
    }
}
