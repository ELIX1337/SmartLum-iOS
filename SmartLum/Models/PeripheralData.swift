//
//  PeripheralData.swift
//  SmartLum
//
//  Created by ELIX on 15.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

struct PeripheralDataModel {
    
    var isInitialized: Bool?
    var firmwareVersion: Int?
    var errorCode: Int?
    
    var animationOnSpeed:  (value: Int?, minValue: Int?, maxValue: Int?)
    var animationOffSpeed: (value: Int?, minValue: Int?, maxValue: Int?)
    var animationStep:     (value: Int?, minValue: Int?, maxValue: Int?)
    var ledTimeout:        (value: Int?, minValue: Int?, maxValue: Int?)
    var ledBrightness:     (value: Int?, minValue: Int?, maxValue: Int?)
    var topSensorTriggerDistance: (value: Int?, minValue: Int?, maxValue: Int?)
    var botSensorTriggerDistance: (value: Int?, minValue: Int?, maxValue: Int?)
    
    var primaryColor:       UIColor?
    var secondaryColor:     UIColor?
    var randomColor:        Bool?
    var animationMode:      PeripheralAnimations?
    var animationDirection: PeripheralAnimationDirections?
    
    var ledState: Bool?
}

protocol PeripheralDataElement {
    var code: UInt8  { get }
    var name: String { get }
}

enum PeripheralAnimations: UInt8, CaseIterable, PeripheralDataElement {
    
    case tetris             = 1
    case wave               = 2
    case transfusion        = 3
    case rainbowTransfusion = 4
    case rainbow            = 5
    case `static`           = 6

    var name: String {
        switch self {
        case .tetris:               return "Tetris"
        case .wave:                 return "Wave"
        case .transfusion:          return "Transfusion"
        case .rainbowTransfusion:   return "Rainbow transfusion"
        case .rainbow:              return "Rainbow"
        case .static:               return "Static"
        }
    }
    var code: UInt8 {{ return self.rawValue }()}
}

enum PeripheralAnimationDirections: UInt8, CaseIterable, PeripheralDataElement {
    
    case fromBottom = 1
    case fromTop    = 2
    case toCenter   = 3
    case fromCenter = 4
    
    var name: String {
        switch self {
        case .fromBottom: return "From bottom"
        case .fromTop:    return "From top"
        case .toCenter:   return "To center"
        case .fromCenter: return "From center"
        }
    }
    
    var code: UInt8 {{ return self.rawValue }()}
}
