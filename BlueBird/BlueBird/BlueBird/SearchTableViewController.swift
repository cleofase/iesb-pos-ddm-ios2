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
    
//    fileprivate var tweets = [Array<Twitter.Tweet>]()
    var tweets = [Array<Twitter.Tweet>]()

    var searchText: String? {
        didSet {
            searchForTweets(with: searchText!)
            title = searchText
        }
    }
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func searchForTweets(with criteria: String) {
        if !criteria.isEmpty {
            let request = Twitter.Request(search: criteria, count: 100)
            request.fetchTweets {[weak self] newTweets in
                DispatchQueue.main.async {
                    self?.insertTweets(newTweets)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
