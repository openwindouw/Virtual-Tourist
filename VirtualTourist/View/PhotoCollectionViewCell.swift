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
    
    let selectedAlpha: CGFloat = 0.5
    let deselectedAlpha: CGFloat = 1
    
    override var isSelected: Bool {
        didSet {
            performUIUpdatesOnMain {
                self.photoImageView.alpha = self.isSelected ? self.selectedAlpha : self.deselectedAlpha
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(selectedAlpha)
        photoImageView.layer.cornerRadius = VTConstants.Metrics.CornerRadius

        photoImageView.image = UIImage(named: "placeholder-1")
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
        super.prepareForReuse()
    }
}
