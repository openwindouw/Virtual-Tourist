//
//  PINDetailViewController.swift
//  VirtualTourist
//
//  Created by administrator on 1/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit

class PINDetailViewController: CustomViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var photos: [FlickrPhoto] = []
    var bbox: String!
    
    var maxPhotos: Int!
    
    var selectedAnnotation: MKAnnotation!
    
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    var itemWidth = CGFloat.leastNormalMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        newCollectionButton.isEnabled = false
        
        maxPhotos = min(photos.count, VTConstants.Flickr.MaxPhotos)
        
        performUIUpdatesOnMain {
            self.mapView.showAnnotations([self.selectedAnnotation], animated: true)
        }
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func newCollectionButtonOnTap(_ sender: Any) {
        FlickrHandler.shared().getPhotos(with: bbox, in: self, onCompletion: { photos in
            self.photos = photos
            self.collectionView.reloadData()
        })
    }
    
}

extension PINDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoDetailCellID", for: indexPath) as! PhotoCollectionViewCell

        let photo = photos[indexPath.row]
        
        if let image = photo.image {
            cell.photoImageView.image = image
        } else if let link = photo.url {
            cell.showActivityIndicator()
            
            Util.downloadImageFrom(link: link) { image in
                cell.hideActivityIndicator()
                
                self.photos[indexPath.row].image = image
                
                if let visibleCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    visibleCell.photoImageView.image = image
                }
                
                self.enableNewCollectionButton(with: indexPath)
                
            }
        }
        
        return cell
    }
}

extension PINDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photos.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        collectionView.reloadData()
    }
}

extension PINDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView?.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
}

extension PINDetailViewController {
    //MARK: Helpers
    func enableNewCollectionButton(with indexPath: IndexPath) {
        if indexPath.row == (maxPhotos - 1) {
            self.newCollectionButton.isEnabled = true
        }
    }
}




