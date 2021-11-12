//
//  RootViewController.swift
//  SmartLum
//
//  Created by Tim on 20/10/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class RootViewController: UINavigationController {
    
    private let primaryTextColor = UIColor(named: "SmartLum Primary Text")
    private let smartlumColor = UIColor(named: "SmartLum Color")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.dynamicColor(light: smartlumColor ?? .SLWhite, dark: smartlumColor ?? .SLBlue)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.dynamicColor(light: primaryTextColor ?? .SLDarkBlue, dark: primaryTextColor ?? .SLYellow)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.dynamicColor(light: primaryTextColor ?? .SLDarkBlue, dark: primaryTextColor ?? .SLYellow)]
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
}
