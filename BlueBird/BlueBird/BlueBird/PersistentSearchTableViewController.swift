//
//  PersistentSearchTableViewController.swift
//  BlueBird
//
//  Created by HC5MAC09 on 24/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class PersistentSearchTableViewController: SearchTableViewController {
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        container?.performBackgroundTask {context in
            for twiiterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twiiterInfo, in: context)
            }
            try? context.save()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mention" {
            if let destinationViewController = segue.destination as? TweetDetailTableViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)
                destinationViewController.tweet = tweets[indexPath!.section][indexPath!.row]
            }
        }

        if segue.identifier == "tweeters" {
            if let destinationViewController = segue.destination as? TweeterTableViewController {
                destinationViewController.container = container
                destinationViewController.searchText = searchText
            }
        }

    }
}
