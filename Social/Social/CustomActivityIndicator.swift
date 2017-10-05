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
    
    private var backMask = UIView()
    private var indicadorSquareIcon = UIView()
    private var activityIndicatorIcon = UIActivityIndicatorView()
    
    func show(at view: UIView) {
        backMask.frame = view.frame
        backMask.center = view.center
        backMask.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3)
        
        indicadorSquareIcon.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        indicadorSquareIcon.center = view.center
        indicadorSquareIcon.backgroundColor =  UIColor(displayP3Red: 63, green: 63, blue: 63, alpha: 0.7)
        indicadorSquareIcon.clipsToBounds = true
        indicadorSquareIcon.layer.cornerRadius = 10
        
        activityIndicatorIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorIcon.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorIcon.center = CGPoint(x: indicadorSquareIcon.frame.midX, y: indicadorSquareIcon.frame.midY)
        
        indicadorSquareIcon.addSubview(activityIndicatorIcon)
        backMask.addSubview(indicadorSquareIcon)
        view.addSubview(backMask)
        activityIndicatorIcon.startAnimating()
    }
    
    func hide() {
        if activityIndicatorIcon.isAnimating {
            activityIndicatorIcon.stopAnimating()
            backMask.removeFromSuperview()
        }
    }
    
}
