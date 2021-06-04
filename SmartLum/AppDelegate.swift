//
//  AppDelegate.swift
//  SmartLum
//
//  Created by Tim on 04/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth
//import AppTrackingTransparency
//import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Required for the Storyboard to show up.
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //requestTrackingAuthorization()
       return true
    }
    
/* No need right now */
//    private func requestTrackingAuthorization() {
//        guard #available(iOS 14, *) else { return }
//        ATTrackingManager.requestTrackingAuthorization { status in
//            DispatchQueue.main.async {
//                switch status {
//                case .authorized:
//                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
//                    print("Пользователь разрешил доступ. IDFA: ", idfa)
//                case .denied, .restricted:
//                    print("Пользователь запретил доступ.")
//                case .notDetermined:
//                    print("Пользователь ещё не получил запрос на авторизацию.")
//                @unknown default:
//                    break
//                }
//            }
//        }
//    }

}

