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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.backgroundColor = UIColor.darkGray
    }
    
}
