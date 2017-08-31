//
//  TweetDetailTableViewController.swift
//  BlueBird
//
//  Created by Cleofas Pereira on 16/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweet != nil {
            switch section {
            case 0: // media
                return tweet!.media.count
            case 1: // hashtags
                return tweet!.hashtags.count
            case 2: // user mentions
                return tweet!.userMentions.count
            case 3: // URLs
                return tweet!.urls.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reusableImageCell", for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = tweet?.media[indexPath.row].url
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMentionCell", for: indexPath)
            if let mentionCell = cell as? MentionTableViewCell {
                mentionCell.mention = tweet?.hashtags[indexPath.row].keyword
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMentionCell", for: indexPath)
            if let mentionCell = cell as? MentionTableViewCell {
                mentionCell.mention = tweet?.userMentions[indexPath.row].keyword
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMentionCell", for: indexPath)
            if let mentionCell = cell as? MentionTableViewCell {
                mentionCell.mention = tweet?.urls[indexPath.row].keyword
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if let imageRatio = tweet?.media[indexPath.row].aspectRatio {
                return tableView.bounds.size.width / CGFloat(imageRatio)
            } else {
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: // media
            return "Imagens"
        case 1: // hashtags
            return "Hashtags"
        case 2: // user mentions
            return "Usuários"
        case 3: // URLs
            return "URLs"
        default:
            return " "
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SearchTableViewController {
            if let cell = sender as? MentionTableViewCell {
                destinationViewController.searchText = cell.mention
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
