//
//  ViewController.swift
//  VirtualTourist
//
//  Created by user on 12/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit

enum EditState {
    case editing, normal
}

class MapViewController: CustomViewController {
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var currentEditState: EditState! = .normal
    
    var selectedAnnotation: MKAnnotation!
    let buttonHeigh: CGFloat = 40
    var annotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonHeightConstraint.constant = .leastNormalMagnitude
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @IBAction func editButtonOnTap(_ sender: Any) {
        if currentEditState == .normal {
            editButton.title = "Done"
            buttonHeightConstraint.constant = buttonHeigh
            currentEditState = .editing
        } else {
            editButton.title = "Edit"
            buttonHeightConstraint.constant = .leastNormalMagnitude
            currentEditState = .normal
        }

    }
    
    @objc func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        
        guard currentEditState == .normal else { return }
        guard sender.state == UIGestureRecognizerState.began else { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let coordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if currentEditState == .editing {
            
            if let currentAnnotation = view.annotation, let currentPointAnnotationIndex = annotations.index (where: {
                return $0.coordinate.latitude == currentAnnotation.coordinate.latitude && $0.coordinate.longitude == currentAnnotation.coordinate.longitude
            }) {
                annotations.remove(at: currentPointAnnotationIndex)
                
                performUIUpdatesOnMain {
                    mapView.removeAnnotation(currentAnnotation)
                }
            }
            
        } else {
            selectedAnnotation = view.annotation
            
            mapView.deselectAnnotation(view.annotation, animated: true)
            
            let bbox = Util.getBoundingBox(for: selectedAnnotation.coordinate.latitude, and: selectedAnnotation.coordinate.longitude)
            
            let performToDetailViewController: (MKAnnotation, [FlickrPhoto]) -> Void = {  annotation, photos in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pinDetailViewController = storyboard.instantiateViewController(withIdentifier: "PinDetailViewControllerID") as! PINDetailViewController
                pinDetailViewController.selectedAnnotation = annotation
                pinDetailViewController.photos = photos
                pinDetailViewController.bbox = bbox
                
                self.navigationController?.pushViewController(pinDetailViewController, animated: true)
                
            }
            
            FlickrHandler.shared().getPhotos(with: bbox, in: self, onCompletion: { photos in
                performToDetailViewController(self.selectedAnnotation, photos)
            })
        }

    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.coordinate)
    }
}

