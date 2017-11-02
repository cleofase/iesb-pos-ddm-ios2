//
//  DetailUserViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 20/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import Photos
import CoreData

class DetailUserViewController: UIViewController {
    var user: User?

    fileprivate var container: NSPersistentContainer? = AppDelegate.persistentContainer
    fileprivate var fetchedResultsController: NSFetchedResultsController<Album>?
    fileprivate var jsonDataAlbums = Data()

    fileprivate let activityIndicator = CustomActivityIndicator()
    @IBOutlet weak var imageUserImageView: UIImageView! {
        didSet {
            let changeImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(changeUserImage(_:)))
            imageUserImageView.addGestureRecognizer(changeImageTapGesture)
        }
    }
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var websiteIconImageView: UIImageView!
    @IBOutlet weak var emailUserLabel: UILabel!
    @IBOutlet weak var websiteUserLabel: UILabel!
    @IBOutlet weak var albumUserTableView: UITableView! {
        didSet {
            albumUserTableView.dataSource = self
            albumUserTableView.estimatedRowHeight = albumUserTableView.rowHeight
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = user else { return }

        title = user?.name
        emailUserLabel.text = user?.email
        websiteUserLabel.text = user?.website
        if let imageData = user?.image, let imageUser = UIImage(data: imageData) {
            imageUserImageView.image = imageUser
        }
        if Reachability.isInternetAvailable() {
            getAlbumsFromService(matching: user!)
        } else {
            updateUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changeUserImage(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        self.present(picker, animated: true, completion: nil)
    }

    private func updateUI() {
        DispatchQueue.main.async {[weak self] in
            if let context = self?.container?.viewContext {
                if let user = self?.user {
                    let request: NSFetchRequest<Album> = Album.fetchRequest()
                    request.predicate = NSPredicate(format: "user.identifier == %i", user.identifier)
                    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                    
                    self?.fetchedResultsController = NSFetchedResultsController<Album>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                    self?.fetchedResultsController?.delegate = self
                    try? self?.fetchedResultsController?.performFetch()
                    self?.albumUserTableView.reloadData()
                    self?.activityIndicator.hide()
                }
            }
        }
    }

    private func getAlbumsFromService(matching user: User) {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        
        let urlSession = URLSession(configuration: RESTDefinitions.urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
        
        var request = URLRequest(url: RESTDefinitions.uriAlbums(withUser: user.identifier))
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = urlSession.dataTask(with: request)

        jsonDataAlbums.removeAll()

        activityIndicator.show(at: UIApplication.shared.keyWindow!, with: .fullView)
        dataTask.resume()
    }
    
    fileprivate func updateDatabase(with albums: [JPHAlbum], _ completionHandler: @escaping () -> Void) {
        container?.performBackgroundTask {context in
            for albumInfo in albums {
                _ = try? Album.findOrCreate(matching: albumInfo, in: context)
            }
            try? context.save()
            completionHandler()
        }
    }
}

extension DetailUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageUserImageView.image = pickedImage
            container?.performBackgroundTask {[unowned self] context in
                self.user?.image = UIImagePNGRepresentation(pickedImage)
                try? context.save()
            }

        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension DetailUserViewController: UITableViewDataSource {
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

extension DetailUserViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonDataAlbums.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
          let decoder = JSONDecoder()
            do {
                let jphAlbums = try decoder.decode([JPHAlbum].self, from: jsonDataAlbums)
                DispatchQueue.main.async {[unowned self] in
                    self.updateDatabase(with: jphAlbums, self.updateUI)
                }
            } catch {
                debugPrint(error)
            }
        } else {
            debugPrint(error!)
        }
    }
}

extension DetailUserViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumUserTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch  type {
        case .insert:
            albumUserTableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            albumUserTableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            albumUserTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            albumUserTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            albumUserTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            albumUserTableView.deleteRows(at: [indexPath!], with: .fade)
            albumUserTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumUserTableView.endUpdates()
    }
}

