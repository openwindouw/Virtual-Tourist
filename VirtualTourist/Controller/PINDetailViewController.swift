//
//  PINDetailViewController.swift
//  VirtualTourist
//
//  Created by administrator on 1/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit

enum PhotoAction {
    case get, delete
}

class PINDetailViewController: CustomViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var emptyCollectionCover: UIView!
    
    var photos: [FlickrPhoto] = []
    var selectedPhotos: [FlickrPhoto] = []
    
    
    var currentAction: PhotoAction! = .get
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
        collectionView.allowsMultipleSelection = true
        
        //setup mapView
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        actionButton.isEnabled = false
        
        //set max photos number
        maxPhotos = min(photos.count, VTConstants.Flickr.MaxPhotos)
        
        emptyCollectionCover.isHidden = true
        
        //show empty cover if photos array is empty
        if photos.isEmpty {
            setupEmptyCollection()
        }
        
        //show selectedAnnotation
        performUIUpdatesOnMain {
            self.mapView.showAnnotations([self.selectedAnnotation], animated: true)
        }
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func actionButtonOnTap(_ sender: Any) {
        if currentAction == .get {
            FlickrHandler.shared().getPhotos(with: bbox, in: self, onCompletion: { photos in
                
                if photos.isEmpty {
                    self.setupEmptyCollection()
                } else {
                    self.photos = photos
                    self.collectionView.reloadData()
                }
                
            })
        } else {
            
            print("before deleted: \(photos.count)")
            
            photos = photos.filter { photo in
                return selectedPhotos.first(where: { selectedPhoto in
                    return selectedPhoto == photo
                }) == nil
            }
            
            print("after deleted: \(photos.count)")
            
            setupForNewCollection()
            collectionView.reloadData()
        }
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
                    
                    performUIUpdatesOnMain {
                        visibleCell.photoImageView.image = image
                    }
                    
                }
                
                self.enableNewCollectionButton(with: indexPath)
                
            }
        }
        
        return cell
    }
}

extension PINDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotos.append(photoFor(indexPath))
        setupForDeleteSelectedPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedPhotos.index(of: photoFor(indexPath)) {
            selectedPhotos.remove(at: index)
        }
        
        if selectedPhotos.isEmpty {
            setupForNewCollection()
        }
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
            self.actionButton.isEnabled = true
        }
    }
    
    func setupEmptyCollection() {
        self.collectionView.isHidden = true
        self.emptyCollectionCover.isHidden = false
        self.actionButton.isEnabled = false
    }
    
    func setupForNewCollection() {
        actionButton.setTitle("New Collection", for: .normal)
        currentAction = .get
    }
    
    func setupForDeleteSelectedPhotos() {
        actionButton.setTitle("Delete Photos", for: .normal)
        currentAction = .delete
    }
    
    func photoFor(_ indexPath: IndexPath) -> FlickrPhoto {
        return photos[indexPath.row]
    }
}




