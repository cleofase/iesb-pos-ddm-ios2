//
//  Photo.swift
//  Social
//
//  Created by Cleofas Pereira on 25/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    class func findOrCreate(matching photoInfo: JPHPhoto, in context: NSManagedObjectContext) throws -> Photo {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "title = %@", photoInfo.title)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Inconsistência no banco de dados! Encontrado mais de uma Photo com o mesmo nome.")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        do {
            let album = try Album.find(matching: photoInfo.albumId, in: context)
            assert(album != nil, "Album da foto, não encontrado.")
            let photo = Photo(context: context)
            photo.identifier = Int32(photoInfo.id)
            photo.title = photoInfo.title
            photo.imageUrl = photoInfo.url
            photo.thumbnailUrl = photoInfo.thumbnailUrl
            photo.album = album
            return photo
        } catch {
            throw error
        }
    }
}
