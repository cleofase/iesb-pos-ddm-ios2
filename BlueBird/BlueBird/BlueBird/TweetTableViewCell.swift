//
//  TweetTableViewCell.swift
//  BlueBird
//
//  Created by Cleofas Pereira on 12/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var tweetElapsedTime: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private var session = URLSession(configuration: .default)
    
    private func updateUI() {
        tweetText?.text = tweet?.text
        userName?.text = tweet?.user.name
        if let _ = tweet?.user.screenName {
            userScreenName?.text = "@\(tweet!.user.screenName)"
        }
        
        userImage?.image = nil
        if let profileImageURL = tweet?.user.profileImageURL {
            let task = session.dataTask(with: profileImageURL, completionHandler: {[unowned self](data: Data?, response: URLResponse?, error: Error?) in
                if let imageData = data {
                    DispatchQueue.main.async {
                        self.userImage?.image = UIImage(data: imageData)
                    }
                }
            })
            task.resume()
        }
        
        if let createdAt = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(createdAt) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetElapsedTime?.text = formatter.string(from: createdAt)
        } else {
            tweetElapsedTime?.text = nil
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
