//
//  Address.swift
//  Social
//
//  Created by Cleofas Pereira on 30/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Address: NSManagedObject {
    class func create(matching addressInfo: JPHAddress, in context: NSManagedObjectContext) throws -> Address {
        let address = Address(context: context)
        address.street = addressInfo.street
        address.suite = addressInfo.suite
        address.city = addressInfo.city
        address.zipcode = addressInfo.zipcode
        return address
    }
}
