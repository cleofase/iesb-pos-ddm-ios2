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
            let session = URLSession(configuration: .default)

            let photo = Photo(context: context)
            photo.identifier = Int32(photoInfo.id)
            photo.title = photoInfo.title
            photo.album = album
            
            if let imageURL = URL(string: photoInfo.url) {
                let task = session.dataTask(with: imageURL) {[unowned photo] (data: Data?, response: URLResponse?, error: Error?) in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            photo.image = imageData
                        }
                    }
                }
                task.resume()
            }

            if let thumbnailURL = URL(string: photoInfo.thumbnailUrl) {
                let task = session.dataTask(with: thumbnailURL) {[unowned photo] (data: Data?, response: URLResponse?, error: Error?) in
                    if let thumbnailData = data {
                        DispatchQueue.main.async {
                            photo.thumbnail = thumbnailData
                        }
                    }
                }
                task.resume()
            }
            return photo
        } catch {
            throw error
        }
    }
}
