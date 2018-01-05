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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
   
//        if let layout = collectionView.collectionViewLayout as? FlickrLayout {
//
//        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func orientationDidChange(notification: Notification) {
        print("hoho")
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




