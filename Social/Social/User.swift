//
//  User.swift
//  Social
//
//  Created by Cleofas Pereira on 24/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject {
    class func findOrCreate(matching userInfo: JPHUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", userInfo.name)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Inconsistência no banco de dados! Encontrado mais de um Usuário com o mesmo identificador.")
                return matches[0]
            }
        } catch {
            throw error
        }
        let user = User(context: context)
        user.identifier = Int32(userInfo.id)
        user.name = userInfo.name
        user.username = userInfo.username
        user.email = userInfo.email
        user.phone = userInfo.phone
        user.website = userInfo.website
        do {
            user.address = try Address.create(matching: userInfo.address, in: context)
        } catch {
            throw error
        }
        do {
            user.company = try Company.create(matching: userInfo.company, in: context)
        } catch {
            throw error
        }
        return user
    }
    
}
