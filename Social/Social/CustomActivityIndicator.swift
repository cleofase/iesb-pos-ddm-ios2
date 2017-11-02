//
//  CustomActivityIndicator.swift
//  Social
//
//  Created by Cleofas Pereira on 05/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import Foundation
import UIKit

class CustomActivityIndicator {
    enum ActivityIndicatorType {
        case onlyIcon
        case fullView
    }
    var animatingType: ActivityIndicatorType?
    
    private var backMask = UIView()
    private var iconMask = UIView()
    private var activityIndicatorIcon = UIActivityIndicatorView()
    private var activityMessage = UILabel()
    
    func show(at view: UIView, with type: ActivityIndicatorType) {
        animatingType = type
        view.addSubview(configuredIndicatorIcon(at: view, with: type))
        activityIndicatorIcon.startAnimating()
    }

    func configuredIndicatorIcon(at view: UIView, with type: ActivityIndicatorType) -> UIView {
        switch type {
        case .onlyIcon:
            activityIndicatorIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            activityIndicatorIcon.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityIndicatorIcon.center = CGPoint(x: view.frame.width/2 , y: view.frame.height/2)
            return activityIndicatorIcon
        case .fullView:
            backMask.frame = view.frame
            backMask.center = view.center
            backMask.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            
            iconMask.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            iconMask.center = view.center
            iconMask.backgroundColor =  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.9)
            iconMask.clipsToBounds = true
            iconMask.layer.cornerRadius = 10
            
            activityMessage.text = "Carregando..."
            activityMessage.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            activityMessage.font = activityMessage.font.withSize(8)
            activityMessage.textAlignment = .center
            activityMessage.frame = CGRect(x: 0, y: 0, width: 64, height: 31)
            activityMessage.center = CGPoint(x: iconMask.frame.width/2, y: iconMask.frame.height/1.2)
            
            activityIndicatorIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicatorIcon.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicatorIcon.center = CGPoint(x: iconMask.frame.width/2, y: iconMask.frame.height/2)
            
            iconMask.addSubview(activityMessage)
            iconMask.addSubview(activityIndicatorIcon)
            backMask.addSubview(iconMask)
            
            return backMask
        }
    }
    
    func hide() {
        if activityIndicatorIcon.isAnimating {
            activityIndicatorIcon.stopAnimating()
            switch animatingType! {
            case .onlyIcon:
                    activityIndicatorIcon.removeFromSuperview()
            case .fullView:
                    backMask.removeFromSuperview()
            }
            animatingType = nil
        }
    }
}
