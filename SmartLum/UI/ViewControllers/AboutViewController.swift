//
//  AboutViewController.swift
//  SmartLum
//
//  Created by Tim on 25.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import AcknowList

/// ViewController окна about
class AboutViewController: UIViewController {
    
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var btnTerms: UIButton!
    @IBOutlet private weak var btnThirdParty: UIButton!
    @IBOutlet private weak var btnPrivacy: UIButton!
    @IBOutlet private weak var btnInstagram: UIButton!
    @IBOutlet private weak var btnVK: UIButton!
    @IBOutlet private weak var btnYoutube: UIButton!
    @IBOutlet private weak var btnWEB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        self.title = "about_window_title".localized
        btnTerms.setTitle("button_terms_and_conditions".localized, for: .normal)
        btnThirdParty.setTitle("button_third_party".localized, for: .normal)
        btnPrivacy.setTitle("button_privacy".localized, for: .normal)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
           versionLabel.text = version
        }
    }
    
    @IBAction private func onButtonTapped(sender: UIButton) {
        switch sender {
        case btnTerms:
            openURL(url: WebURLs.Terms)
            break
        case btnThirdParty:
            showThirdPartyLibraries()
            break
        case btnPrivacy:
            openURL(url: WebURLs.Privacy)
            break
        case btnInstagram:
            openURL(url: WebURLs.Instagram)
            break
        case btnVK:
            openURL(url: WebURLs.VK)
            break
        case btnYoutube:
            openURL(url: WebURLs.Youtube)
            break
        case btnWEB:
            openURL(url: WebURLs.Website)
            break
        default:
            break
        }
    }

    
    private func openURL(url: URL?) {
        if let site = url,
            UIApplication.shared.canOpenURL(site) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(site)
            } else {
                UIApplication.shared.openURL(site)
            }
        }
    }
    
    /// Метод, который откроет ViewController со всеми используемыми библиотеками в приложении.
    private func showThirdPartyLibraries() {
        var vc = AcknowListViewController()
        let path = Bundle.main.path(forResource: "Pods-SmartLum-acknowledgements", ofType: "plist")
        if let p = path {
            if #available(iOS 13.0, *) {
                vc = AcknowListViewController(plistPath: p, style: .insetGrouped)
            } else {
              vc = AcknowListViewController(plistPath: p)
            }
        } else {
            vc = AcknowListViewController(fileNamed: "Pods-SmartLum-acknowledgements")
        }
        vc.title = "third_party_libraries_window_title".localized
        vc.headerText = "third_party_libraries_window_header".localized
        vc.footerText = "2021 SmartLum ©"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

