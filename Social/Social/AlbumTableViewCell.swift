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
    var album: Album? {
        didSet{
            if let _ = album {
                titleAlbumLabel.text = album?.title
                if Reachability.isInternetAvailable() {
                    createSession()
                    getPhotosFromService(matching: album!)
                } else {
                    updateUI()
                }
            }
        }
    }

    fileprivate var container: NSPersistentContainer? = AppDelegate.persistentContainer
    fileprivate var fetchedResultsController: NSFetchedResultsController<Photo>?
    fileprivate var urlSession: URLSession?
    fileprivate var jsonDataPhotos = Data()

    @IBOutlet weak var titleAlbumLabel: UILabel!
    @IBOutlet weak var albumCollectionView: UICollectionView! {
        didSet {
            albumCollectionView.dataSource = self
            albumCollectionView.delegate = self
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        jsonDataPhotos.removeAll()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {[weak self] in
            if let context = self?.container?.viewContext {
                if let album = self?.album {
                    let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                    request.predicate = NSPredicate(format: "album.identifier == %i", album.identifier)
                    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                    
                    self?.fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                    self?.fetchedResultsController?.delegate = self
                    try? self?.fetchedResultsController?.performFetch()
                    self?.albumCollectionView.reloadData()
                }
            }
        }
    }
    
    private func createSession() {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 100
        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        
        urlSession = URLSession(configuration: RESTDefinitions.urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
    }
    
    private func getPhotosFromService(matching album: Album) {
        var request = URLRequest(url: RESTDefinitions.uriPhotos(withAlbum: album.identifier))
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = urlSession?.dataTask(with: request)
        jsonDataPhotos.removeAll()
        dataTask?.resume()
    }

    fileprivate func updateDatabase(with photos: [JPHPhoto], _ completionHandler: @escaping () -> Void) {
        container?.performBackgroundTask {context in
            for photoInfo in photos {
                _ = try? Photo.findOrCreate(matching: photoInfo, in: context)
            }
            try? context.save()
            completionHandler()
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
        let context = container?.newBackgroundContext()
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "reusePhotoCell", for: indexPath)
        if let photoCell = cell as? PhotoAlbumCollectionViewCell {
            if let photo = fetchedResultsController?.object(at: indexPath) {
                photoCell.context = context
                photoCell.session = urlSession
                photoCell.photo = photo
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
                    self.updateDatabase(with: jphPhotos, self.updateUI)
                }
            } catch {
                debugPrint("Erro convertendo json: \(error)")
            }
        } else {
            debugPrint("Erro baixando json: \(error!)")
        }
    }
}

extension AlbumTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}
