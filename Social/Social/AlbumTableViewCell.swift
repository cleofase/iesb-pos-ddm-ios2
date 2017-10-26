//
//  AlbumTableViewCell.swift
//  Social
//
//  Created by Cleofas Pereira on 25/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class AlbumTableViewCell: UITableViewCell {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer

    fileprivate let activityIndicator = CustomActivityIndicator()
    fileprivate var jsonDataPhotos = Data()

    @IBOutlet weak var titleAlbumLabel: UILabel!
    @IBOutlet weak var albumCollectionView: UICollectionView! {
        didSet {
            albumCollectionView.dataSource = self
        }
    }
    
    var album: Album? {
        didSet {
            titleAlbumLabel.text = album?.title
            if Reachability.isInternetAvailable() {
                if let _ = album {
                    getPhotosFromService(matching: album!)
                }
            }
        }
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Photo>?
    
    private func updateUI() {
        if let context = container?.viewContext {
            if let _ = album {
                let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                request.predicate = NSPredicate(format: "album.identifier == %i", album!.identifier)
                request.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                
                fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.delegate = self
                try? fetchedResultsController?.performFetch()
                albumCollectionView.reloadData()
            }
        }
    }
    
    private func getPhotosFromService(matching album: Album) {
        let getPhotosURI = "https://jsonplaceholder.typicode.com/albums/\(album.identifier)/photos"
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.allowsCellularAccess = true
        urlSessionConfiguration.networkServiceType = .default
        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        urlSessionConfiguration.isDiscretionary = true
        urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 4096, diskPath: NSTemporaryDirectory())
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
        
        if let urlGetPhotosURI = URL(string: getPhotosURI) {
            activityIndicator.show(at: UIApplication.shared.keyWindow!)
            var request = URLRequest(url: urlGetPhotosURI)
            request.timeoutInterval = 60
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = urlSession.dataTask(with: request)
            jsonDataPhotos.removeAll()
            dataTask.resume()
        }
    }

    fileprivate func updateDatabase(with photos: [JPHPhoto]) {
        container?.performBackgroundTask {context in
            for photoInfo in photos {
                _ = try? Photo.findOrCreate(matching: photoInfo, in: context)
            }
            try? context.save()
        }
    }

    
}

extension AlbumTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = fetchedResultsController?.fetchedObjects?.count
        return numberOfItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "reusePhotoCell", for: indexPath)
        if let photoCell = cell as? PhotoAlbumCollectionViewCell {
            if let dataPhoto = fetchedResultsController?.object(at: indexPath).thumbnail, let photoImage = UIImage(data:dataPhoto) {
                photoCell.photo = photoImage
                return photoCell
            }
        }
        return cell
    }
}

extension AlbumTableViewCell: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch  type {
        case .insert:
            albumCollectionView.insertSections([sectionIndex])
        case .delete:
            albumCollectionView.deleteSections([sectionIndex])
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            albumCollectionView.insertItems(at: [newIndexPath!])
        case .delete:
            albumCollectionView.deleteItems(at: [newIndexPath!])
        case .update:
            albumCollectionView.reloadItems(at: [newIndexPath!])
        case .move:
            albumCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
}

extension AlbumTableViewCell: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonDataPhotos.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            let decoder = JSONDecoder()
            do {
                let jphPhotos = try decoder.decode([JPHPhoto].self, from: jsonDataPhotos)
                DispatchQueue.main.async {[unowned self] in
                    self.updateDatabase(with: jphPhotos)
                    self.updateUI()
                    self.activityIndicator.hide()
                }
            } catch {
                debugPrint(error)
            }
        } else {
            debugPrint(error!)
        }
    }
}
