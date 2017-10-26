//
//  PhotoUserViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 20/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import Photos
import CoreData

class PhotoUserViewController: UIViewController {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer

    var user: User?
    var fetchedResultsController: NSFetchedResultsController<Album>?
    
    fileprivate var jsonDataAlbums = Data()
    fileprivate let activityIndicator = CustomActivityIndicator()


    @IBOutlet weak var imageUserImageView: UIImageView!
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var websiteIconImageView: UIImageView!
    @IBOutlet weak var emailUserLabel: UILabel!
    @IBOutlet weak var websiteUserLabel: UILabel!
    @IBAction func changeImageUserButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        self.present(picker, animated: true, completion: nil)
    }
    @IBOutlet weak var photoUserTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        photoUserTableView.dataSource = self
        
        if let _ = user {
            emailUserLabel.text = user?.email
            websiteUserLabel.text = user?.website
        }

        if Reachability.isInternetAvailable() {
            if let _ = user {
                getAlbumsFromService(matching: user!)
            }
        }
        photoUserTableView.estimatedRowHeight = photoUserTableView.rowHeight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateUI() {
        if let context = container?.viewContext {
            if let _ = user {
                let request: NSFetchRequest<Album> = Album.fetchRequest()
                request.predicate = NSPredicate(format: "user.identifier == %i", user!.identifier)
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                
                fetchedResultsController = NSFetchedResultsController<Album>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.delegate = self
                try? fetchedResultsController?.performFetch()
                photoUserTableView.reloadData()
            }
        }
    }

    private func getAlbumsFromService(matching user: User) {
        let getAlbumsURI = "https://jsonplaceholder.typicode.com/users/\(user.identifier)/Albums"
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
        
        if let urlGetAlbumsURI = URL(string: getAlbumsURI) {
            activityIndicator.show(at: UIApplication.shared.keyWindow!)
            var request = URLRequest(url: urlGetAlbumsURI)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = urlSession.dataTask(with: request)
            jsonDataAlbums.removeAll()
            dataTask.resume()
        }
    }
    
    fileprivate func updateDatabase(with albums: [JPHAlbum]) {
        container?.performBackgroundTask {context in
            for albumInfo in albums {
                _ = try? Album.findOrCreate(matching: albumInfo, in: context)
            }
            try? context.save()
        }
    }

}

extension PhotoUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageUserImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseAlbumCell", for: indexPath)
        if let albumCell = cell as? AlbumTableViewCell {
            let album = fetchedResultsController?.object(at: indexPath)
            albumCell.album = album
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
}

extension PhotoUserViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonDataAlbums.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            let decoder = JSONDecoder()
            do {
                let jphAlbums = try decoder.decode([JPHAlbum].self, from: jsonDataAlbums)
                DispatchQueue.main.async {[unowned self] in
                    self.updateDatabase(with: jphAlbums)
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

extension PhotoUserViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoUserTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch  type {
        case .insert:
            photoUserTableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            photoUserTableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoUserTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            photoUserTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            photoUserTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            photoUserTableView.deleteRows(at: [indexPath!], with: .fade)
            photoUserTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoUserTableView.endUpdates()
    }
}

