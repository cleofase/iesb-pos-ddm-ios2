//
//  PersistentSearchTableViewController.swift
//  BlueBird
//
//  Created by HC5MAC09 on 24/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class PersistentSearchTableViewController: SearchTableViewController {
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweeters" {
            if let destinationViewController = segue.destination as? TweeterTableViewController {
                destinationViewController.container = container
                destinationViewController.searchText = 
                
            }
        }

    }
}
