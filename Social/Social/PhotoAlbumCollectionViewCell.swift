//
//  PhotoAlbumCollectionViewCell.swift
//  Social
//
//  Created by Cleofas Pereira on 26/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: UIImage? {
        didSet {
            photoImageView.image = photo
        }
    }
}
