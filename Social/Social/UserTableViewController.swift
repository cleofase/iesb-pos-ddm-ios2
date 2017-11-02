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
    fileprivate var container: NSPersistentContainer? = AppDelegate.persistentContainer
    fileprivate var fetchedResultsController: NSFetchedResultsController<User>?
    fileprivate var jsonDataUsers = Data()
    
    fileprivate let activityIndicator = CustomActivityIndicator()
    private func getUsersFromService() {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)

        var request = URLRequest(url: RESTDefinitions.uriUsers())
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let urlSession = URLSession(configuration: RESTDefinitions.urlSessionConfiguration, delegate: self, delegateQueue: operationQueue)
        let dataTask = urlSession.dataTask(with: request)
        
        jsonDataUsers.removeAll()
        
        activityIndicator.show(at: UIApplication.shared.keyWindow!, with: .fullView)
        dataTask.resume()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {[weak self] in
            if let context = self?.container?.viewContext {
                let request: NSFetchRequest<User> = User.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                
                self?.fetchedResultsController = NSFetchedResultsController<User>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                self?.fetchedResultsController?.delegate = self
                try? self?.fetchedResultsController?.performFetch()
                self?.tableView.reloadData()
                self?.activityIndicator.hide()
            }
        }
    }
    
    
    fileprivate func updateDatabase(with users: [JPHUser], _ completionHandler: @escaping () -> Void) {
        container?.performBackgroundTask {context in
            for userInfo in users {
                _ = try? User.findOrCreate(matching: userInfo, in: context)
            }
            try? context.save()
            completionHandler()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isInternetAvailable() {
            getUsersFromService()
        } else {
            updateUI()
        }
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
            let destination = segue.destination as! DetailUserViewController
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
                    self.updateDatabase(with: jphUsers, self.updateUI)
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
