//
//  PhotoAlbumCollectionViewCell.swift
//  Social
//
//  Created by Cleofas Pereira on 26/10/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    var photo: Photo? {
        didSet{
            if let _ = photo {
                updateUI()
            }
        }
    }
    var context: NSManagedObjectContext?
    var session: URLSession?
    
    private var dataTask: URLSessionDataTask?

    private let activityIndicator = CustomActivityIndicator()
    @IBOutlet weak var photoImageView: UIImageView!
    
    private func updateUI() {
        if let dataThumbnail = photo?.thumbnail, let imagePhoto = UIImage(data: dataThumbnail) {
            photoImageView.image = imagePhoto
        } else if let _ = photo?.thumbnailUrl {
            let url = URL(string: "http://lorempixel.com/150/150/")
            getThumbnailFromService(withURL: url!)
        }
    }
    
    private func getThumbnailFromService(withURL url: URL) {
        let dataTask = session?.dataTask(with: url) {[weak self] (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                if let thumbnailData = data {
                    let thumbnailImage = UIImage(data: thumbnailData)
                    DispatchQueue.main.async {[weak self] in
                        self?.photoImageView.image = thumbnailImage
                        self?.activityIndicator.hide()
                    }
                    self?.context?.perform {[weak self] in
                        self?.photo?.thumbnail = thumbnailData
                        try? self?.context?.save()
                    }
                }
            } else {
                print("Ohhh... Erro baixando foto: \(url.debugDescription) Motivo: \(error.debugDescription)")
            }
        }
        activityIndicator.show(at: photoImageView, with: .onlyIcon)
        dataTask?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataTask?.cancel()
        photoImageView.image = nil
        activityIndicator.hide()
    }
}
