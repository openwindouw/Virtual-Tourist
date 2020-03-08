//
//  PINDetailViewController.swift
//  VirtualTourist
//
//  Created by administrator on 1/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

enum PhotoAction {
    case get, delete
}

class PINDetailViewController: CustomViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var emptyCollectionCover: UIView!
    
    var selectedPhotos: [Photo] = []
    
    var pin: Pin!
    
    var currentAction: PhotoAction! = .get
    var bbox: String!
    
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
        
        bbox = Util.getBoundingBox(for: pin.latitude, and: pin.longitude)
        
        emptyCollectionCover.isHidden = true
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: AppDelegate.stack!.context, sectionNameKeyPath: nil, cacheName: nil)
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = pin.coordinate
        
        //show selectedAnnotation
        performUIUpdatesOnMain {
            self.mapView.showAnnotations([pointAnnotation], animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNewCollection() {
            performUIUpdatesOnMain {
                self.setupForNewCollection()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func actionButtonOnTap(_ sender: Any) {
        if currentAction == .get {
            
            for photo in fetchedResultsController?.fetchedObjects as! [Photo] {
                AppDelegate.stack?.context.delete(photo)
            }
            
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
            
            AppDelegate.stack?.save()
            
            getNewCollection() {
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        } else {
            
            selectedPhotos.forEach { photo in
                AppDelegate.stack?.context.delete(photo)
            }
            
            AppDelegate.stack?.save()
            
            setupForNewCollection()
            collectionView.reloadData()
        }
    }
    
}

extension PINDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoDetailCellID", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo

        if let image = photo.image {
            cell.photoImageView.image = UIImage(data: image as Data)
        } else if let link = photo.url {
            
            Util.downloadImageFrom(link: link) { image in
                photo.image = image as NSData
                
                performUIUpdatesOnMain {
                    cell.photoImageView.image = UIImage(data: image)
                }
                
                AppDelegate.stack?.performBackgroundBatchOperation({ backgroundContext in
                    backgroundContext.parent = AppDelegate.stack?.context
                })
            }
        }
        
        return cell
    }
}

extension PINDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotos.append(fetchedResultsController?.object(at: indexPath) as! Photo)
        setupForDeleteSelectedPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedPhotos.firstIndex(of: fetchedResultsController?.object(at: indexPath) as! Photo) {
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
    
    func getNewCollection(onCompletion: (() -> Void)? = nil) {
        if let count = pin.photos?.count, count == 0{
            
            FlickrHandler.shared().getPhotos(with: bbox, in: self, onCompletion: { photos in
                
                guard !photos.isEmpty else {
                    self.setupEmptyCollection()
                    return
                }
                
                photos.forEach { flickrPhoto in
                    let photo = Photo(flickrPhoto: flickrPhoto, context: AppDelegate.stack!.context)
                    photo.pin = self.pin
                }
                
                AppDelegate.stack?.save()
                
                onCompletion?()
            })
        }
    }
    
    func setupEmptyCollection(enable actionIsEnabled: Bool = false) {
        performUIUpdatesOnMain {
            self.collectionView.isHidden = true
            self.emptyCollectionCover.isHidden = false
            self.actionButton.isEnabled = actionIsEnabled
        }
    }
    
    func setupForNewCollection() {
        performUIUpdatesOnMain {
            self.actionButton.isEnabled = true
            self.actionButton.setTitle("New Collection", for: .normal)
            self.currentAction = .get
        }
    }
    
    func setupForDeleteSelectedPhotos() {
        performUIUpdatesOnMain {
            self.actionButton.isEnabled = true
            self.actionButton.setTitle("Delete Photos", for: .normal)
            self.currentAction = .delete
        }
    }
}




