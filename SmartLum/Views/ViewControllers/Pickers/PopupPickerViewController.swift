//
//  PopupPickerViewController.swift
//  SmartLum
//
//  Created by ELIX on 06.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class PopupPickerViewController: UIViewController {
    
    var backgroundView: UIView!
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView = UIView()
        self.containerView  = UIView()
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = UIColor.clear
        self.view.addSubview(backgroundView)
        self.view.addSubview(containerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        self.backgroundView.addGestureRecognizer(tap)
        
        NSLayoutConstraint(item: backgroundView!,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.bottomMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: backgroundView!,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.topMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: backgroundView!,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.trailingMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: backgroundView!,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.leadingMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: containerView!,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view,
                           attribute: NSLayoutConstraint.Attribute.bottomMargin,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: containerView!,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view,
                           attribute: NSLayoutConstraint.Attribute.topMargin,
                           multiplier: 1.0,
                           constant: view.bounds.height/1.5).isActive = true
        NSLayoutConstraint(item: containerView!,
                           attribute: NSLayoutConstraint.Attribute.width,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view,
                           attribute: NSLayoutConstraint.Attribute.width,
                           multiplier: 1,
                           constant: 0).isActive = true

        containerView.heightAnchor.constraint(equalToConstant: 700).isActive = true

        var blurEffect = UIBlurEffect()
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        } else {
            blurEffect = UIBlurEffect(style: .regular)
        }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = containerView.backgroundColor?.withAlphaComponent(0.15)
        containerView.insertSubview(blurEffectView, at: 0)
    }
    
    @objc func onTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
