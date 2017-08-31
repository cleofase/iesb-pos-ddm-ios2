//
//  TwitterUser.swift
//  BlueBird
//
//  Created by HC5MAC09 on 24/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import CoreData
import Twitter

class TwitterUser: NSManagedObject {
    class func findOrCreateTwitterUser(matching twitterInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUser {
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        
    }

}
