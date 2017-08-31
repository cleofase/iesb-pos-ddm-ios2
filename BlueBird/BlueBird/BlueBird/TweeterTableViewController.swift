//
//  TweeterTableViewController.swift
//  BlueBird
//
//  Created by HC5MAC09 on 24/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class TweeterTableViewController: UITableViewController {
    
    var searchText: String? {
        didSet {
            updateUI()
        }
    }
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<TwitterUser>?
    
    private func updateUI() {
        if let context = container?.viewContext, searchText != nil {
            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", searchText!)
            
            fetchedResultsController = NSFetchedResultsController<TwitterUser>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableTweeterCell", for: indexPath)
        
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = twitterUser.handle
            let tweetCount = tweetCountWithUser(twitterUser)
            cell.detailTextLabel?.text = "\(tweetCount) tweet\((tweetCount == 1) ? "" : "s")"
        }
        return cell
    }
    
    private func tweetCountWithUser(_ twitterUser: TwitterUser) -> Int {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "text contains[c] %@ AND tweeter = %@", searchText!, twitterUser)
        return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0
    }


}

extension TweeterTableViewController: NSFetchedResultsControllerDelegate {
    
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
