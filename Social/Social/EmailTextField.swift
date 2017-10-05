//
//  EmailTextField.swift
//  Social
//
//  Created by Cleofas Pereira on 04/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class EmailTextField: UITextField, Validable {
    func isValid() -> Bool {
        if let email = text {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
        } else {
            return false
        }
    }
}
