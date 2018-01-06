//
//  PINDetailViewController.swift
//  VirtualTourist
//
//  Created by administrator on 1/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit

class PINDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedAnnotation: MKAnnotation!
    
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    var itemWidth = CGFloat.leastNormalMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        mapView.showAnnotations([selectedAnnotation], animated: true)
        
        
        let parameters: VTDictionary = [
            "method"  : FlickrHandler.Methods.SearchPhotos,
            "bbox"    : Util.getBoundingBox(for: selectedAnnotation.coordinate.latitude, and: selectedAnnotation.coordinate.longitude),
            "extras"  : "url_m",
            "nojsoncallback" : "1",
            "per_page" : "10"
        ]
        
        FlickrHandler.shared().request(parameters: parameters, completionHandler: { data, error in
            let dictionaryResult = data as! VTDictionary
            print(dictionaryResult)
        })

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoDetailCellID", for: indexPath) as! PhotoCollectionViewCell
        cell.showActivityIndicator()
        return cell
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




