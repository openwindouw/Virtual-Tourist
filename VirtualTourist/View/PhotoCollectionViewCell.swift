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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.backgroundColor = UIColor.lightGray
        photoImageView.layer.cornerRadius = VTConstants.Metrics.CornerRadius
        
        activityView.activityIndicatorViewStyle = .white
    }
    
    func showActivityIndicator() {
        activityView.startAnimating()
    }

    func hideActivityIndicator() {
        activityView.stopAnimating()
        activityView.isHidden = true
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
//        activityView.isHidden = false
        super.prepareForReuse()
    }
}
