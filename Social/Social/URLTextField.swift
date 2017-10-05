//
//  URLTextField.swift
//  Social
//
//  Created by Cleofas Pereira on 04/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class URLTextField: UITextField, Validable {
    func isValid() -> Bool {
        if let url = text {
            let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?"
            return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: url)
        } else {
            return false
        }
    }    
}
