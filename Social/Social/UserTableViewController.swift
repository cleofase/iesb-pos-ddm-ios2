//
//  UserTableViewController.swift
//  Social
//
//  Created by Cleofas Pereira on 24/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class UserTableViewController: UITableViewController {
    var container: NSPersistentContainer? = AppDelegate.persistentContainer

    fileprivate let activityIndicator = CustomActivityIndicator()
    fileprivate var fetchedResultsController: NSFetchedResultsController<User>?
    fileprivate var jsonDataUsers = Data()
    
    private func getUsersFromService() {
        let getUsersURI = "https://jsonplaceholder.typicode.com/users"
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
        
        if let urlGetUsersURI = URL(string: getUsersURI) {
            activityIndicator.show(at: UIApplication.shared.keyWindow!)
            var request = URLRequest(url: urlGetUsersURI)
            request.timeoutInterval = 10
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = urlSession.dataTask(with: request)
            jsonDataUsers.removeAll()
            dataTask.resume()
        }
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            fetchedResultsController = NSFetchedResultsController<User>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    
    fileprivate func updateDatabase(with users: [JPHUser]) {
        container?.performBackgroundTask {context in
            for userInfo in users {
                _ = try? User.findOrCreate(matching: userInfo, in: context)
            }
            try? context.save()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isInternetAvailable() {
            getUsersFromService()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseUserCell", for: indexPath)
        if let user = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.username
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoUserSegue" {
            let destination = segue.destination as! PhotoUserViewController
            let userCell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: userCell)
            destination.user = fetchedResultsController?.object(at: indexPath!)
        }
    }

}

extension UserTableViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        jsonDataUsers.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            let decoder = JSONDecoder()
            do {
                let jphUsers = try decoder.decode([JPHUser].self, from: jsonDataUsers)
                DispatchQueue.main.async {[unowned self] in
                    self.tableView.reloadData()
                    self.updateDatabase(with: jphUsers)
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

extension UserTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch  type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
