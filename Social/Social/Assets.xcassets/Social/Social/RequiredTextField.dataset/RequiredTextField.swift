//
//  RequiredTextField.swift
//  Social
//
//  Created by Cleofas Pereira on 04/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class RequiredTextField: UITextField, Validable {
    func isValid() -> Bool {
        if let _ = text {
            return !text!.isEmpty
        } else {
            return false
        }
    }    
}
