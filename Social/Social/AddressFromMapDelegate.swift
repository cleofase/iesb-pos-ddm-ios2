//
//  AddressFromMapDelegate.swift
//  Social
//
//  Created by Cleofas Pereira on 10/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import Foundation
import CoreLocation

protocol AddressFromMapDelegate {
    func addressFromMap(didUpdateAddressFromMap location: CLLocation)
}
