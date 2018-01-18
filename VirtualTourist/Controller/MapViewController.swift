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
    
    let labelHeight: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonHeightConstraint.constant = .leastNormalMagnitude
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: AppDelegate.stack!.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if let pins = fetchedResultsController?.fetchedObjects as? [Pin] {
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(pins)
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
            buttonHeightConstraint.constant = labelHeight
            currentEditState = .editing
        } else {
            editButton.title = "Edit"
            buttonHeightConstraint.constant = .leastNormalMagnitude
            currentEditState = .normal
        }

    }
    
    @objc func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        
        guard currentEditState == .normal else { return }
        guard sender.state == .ended else { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let pin = Pin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: fetchedResultsController!.managedObjectContext)
        
        print("\(pin)")
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(pin)
        }
        
        AppDelegate.stack?.save()
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
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let pin = view.annotation as? Pin  {
            switch currentEditState {
            case .editing:
                performUIUpdatesOnMain {
                    mapView.removeAnnotation(pin)
                }
                
                AppDelegate.stack?.context.delete(pin)
                AppDelegate.stack?.save()
            default:
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pinDetailViewController = storyboard.instantiateViewController(withIdentifier: "PinDetailViewControllerID") as! PINDetailViewController
                pinDetailViewController.pin = pin
 
                self.navigationController?.pushViewController(pinDetailViewController, animated: true)
            }
            
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

