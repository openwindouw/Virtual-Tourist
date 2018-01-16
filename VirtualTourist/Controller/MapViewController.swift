//
//  ViewController.swift
//  VirtualTourist
//
//  Created by user on 12/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            if let fc = fetchedResultsController {
                do {
                    try fc.performFetch()
                    print("Total PINs: \(fetchedResultsController?.sections?.first?.numberOfObjects ?? 0)")
                } catch let e as NSError {
                    print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
                }
            }
//            print("Total PINs: \(fetchedResultsController?.sections?.first?.numberOfObjects ?? 0)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack

        buttonHeightConstraint.constant = .leastNormalMagnitude
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack!.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if let test = fetchedResultsController?.fetchedObjects as? [Pin] {
            annotations = test.map { pin in
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                return annotation
            }
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(self.annotations)
            }
        }
        
        if let encodedRegion = UserDefaults.standard.value(forKey: VTConstants.UserDefaultsKeys.region) as? VTDictionary {
            performUIUpdatesOnMain {
                self.mapView.setRegion(MKCoordinateRegion(encoded: encodedRegion), animated: true)
            }
        }
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
        
        let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: fetchedResultsController!.managedObjectContext)
        
        print("\(pin)")
        
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(mapView.region.encoded, forKey: VTConstants.UserDefaultsKeys.region)
        userDefaults.synchronize()
    }
}

