//
//  Company.swift
//  Social
//
//  Created by Cleofas Pereira on 30/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Company: NSManagedObject {
    class func create(matching companyInfo: JPHCompany, in context: NSManagedObjectContext) throws -> Company {
        let company = Company(context: context)
        company.name = companyInfo.name
        company.catchPhrase = companyInfo.catchPhrase
        company.bs = companyInfo.bs
        return company
    }
}
