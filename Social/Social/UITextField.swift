//
//  UITextField.swift
//  Social
//
//  Created by Cleofas Pereira on 04/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

extension UITextField {
    func markAsNotValid() {
        self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
    }
    
    func clearMark() {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    }
}
