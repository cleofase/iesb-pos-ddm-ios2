//
//  ImageTableViewCell.swift
//  BlueBird
//
//  Created by Cleofas Pereira on 16/08/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageTweet: UIImageView!
    
    var imageURL: URL? {
        didSet {
            updateUI()
        }
    }
    
    private var session = URLSession(configuration: .default)
    
    private func updateUI() {
        imageTweet?.image = nil
        if let profileImageURL = imageURL {
            let task = session.dataTask(with: profileImageURL, completionHandler: {[unowned self](data: Data?, response: URLResponse?, error: Error?) in
                if let imageData = data {
                    DispatchQueue.main.async {
                        self.imageTweet?.image = UIImage(data: imageData)
                    }
                }
            })
            task.resume()
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
