//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by user on 1/4/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage?
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.backgroundColor = UIColor.darkGray
        
    }
    
    func configure(with link: String) {
        if let image = photoImage {
            photoImageView.image = image
        } else {
            showActivityIndicator()
            
            photoImageView.downloadedFrom(link: link) { image in
                self.photoImage = image
                self.hideActivityIndicator()
            }
        }

    }
    
    func showActivityIndicator() {
        activityView.startAnimating()
    }

    func hideActivityIndicator() {
        activityView.stopAnimating()
    }
}
