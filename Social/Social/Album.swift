//
//  Album.swift
//  Social
//
//  Created by Cleofas Pereira on 25/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Album: NSManagedObject  {
    class func findOrCreate(matching albumInfo: JPHAlbum, in context: NSManagedObjectContext) throws -> Album {
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "title = %@", albumInfo.title)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Inconsistência no banco de dados! Encontrado mais de um Album com o mesmo nome.")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        do {
            let user = try User.find(matching: albumInfo.userId, in: context)
            assert(user != nil, "Usuário proprietário do album, não encontrado.")

            let album = Album(context: context)
            album.identifier = Int32(albumInfo.id)
            album.title = albumInfo.title
            album.user = user
            return album
        } catch {
            throw error
        }
    }
    
    class func find(matching albumIdentifier: Int, in context: NSManagedObjectContext) throws -> Album? {
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %i", albumIdentifier)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Inconsistência no banco de dados! Encontrado mais de um Album com o mesmo identificador.")
                return matches[0]
            }
        } catch {
            throw error
        }
        return nil
    }


}
