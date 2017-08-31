//
//  HashtagTableViewCell.swift
//  BlueBird
//
//  Created by Cleofas Pereira on 16/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class MentionTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetMention: UILabel!
    
    var mention: String? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        tweetMention?.text = mention
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
