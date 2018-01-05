//
//  PINDetailViewController.swift
//  VirtualTourist
//
//  Created by administrator on 1/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class PINDetailViewController: UIViewController {
    @IBOutlet var mapView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    var itemWidth = CGFloat.leastNormalMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
//
//
//        collectionView.contentInsetAdjustmentBehavior = .never
//
        collectionView.dataSource = self
//
//        let layout = UICollectionViewFlowLayout()
//        let collectionViewWidth = collectionView.bounds.width
//
//        itemWidth = ((collectionViewWidth - (sectionInsets.left * (itemsPerRow + 1))) / itemsPerRow)
//
//        layout.sectionInset = sectionInsets
//        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
//        layout.minimumLineSpacing = sectionInsets.left
//        layout.minimumInteritemSpacing = 8
//        layout.headerReferenceSize = CGSize(width: collectionViewWidth, height: collectionViewWidth)
//        collectionView.setCollectionViewLayout(layout, animated: true)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension PINDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoDetailCellID", for: indexPath)
        return cell
    }
}




