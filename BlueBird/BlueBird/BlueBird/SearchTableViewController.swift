//
//  SearchTableViewController.swift
//  BlueBird
//
//  Created by Cleofas Pereira on 12/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import Twitter


class SearchTableViewController: UITableViewController {
    
    @IBOutlet weak var tweetSearchBar: UITextField! {
        didSet {
            tweetSearchBar.delegate = self
        }
    }
    
    fileprivate var tweets = [Array<Twitter.Tweet>]()
    var searchText: String? {
        didSet {
            searchForTweets(with: searchText!)
            title = searchText
        }
    }
    func insertTweets(_ newTweets: [Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func searchForTweets(with criteria: String) {
        if !criteria.isEmpty {
            let request = Twitter.Request(search: criteria, count: 100)
            request.fetchTweets {[weak self] newTweets in
                DispatchQueue.main.async {
                    insertTweets(newTweets)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       // searchText = "#psp"
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableTweetCell", for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mention" {
            if let destinationViewController = segue.destination as? TweetDetailTableViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)
                destinationViewController.tweet = tweets[indexPath!.section][indexPath!.row]
            }
        }
            
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tweetSearchBar {
            searchText = textField.text
            textField.resignFirstResponder()
            tweets.removeAll()
            tableView.reloadData()
        }
        return true
    }
}
