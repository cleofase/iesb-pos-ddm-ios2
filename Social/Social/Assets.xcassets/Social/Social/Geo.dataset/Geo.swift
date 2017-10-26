//
//  Geo.swift
//  Social
//
//  Created by Cleofas Pereira on 30/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Geo: NSManagedObject {
    class func create(matching geoInfo: JPHGeo, in context: NSManagedObjectContext) throws -> Geo {
        let geo = Geo(context: context)
        geo.lat = geoInfo.lat
        geo.lng = geoInfo.lng
        return geo
    }
}
