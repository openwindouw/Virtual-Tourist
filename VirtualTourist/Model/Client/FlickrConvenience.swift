//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by user on 1/7/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

extension FlickrHandler {
    func getPhotos(with boundingBox: String, in viewController: CustomViewController, onCompletion: @escaping ([FlickrPhoto]) -> Void) {
        
        let randomPage = min(Int(arc4random_uniform(UInt32(VTConstants.Flickr.MaxPage))) + 1, VTConstants.Flickr.MaxPage)
        
        let parameters: VTDictionary = [
            "method"  : FlickrHandler.Methods.SearchPhotos,
            "bbox"    : boundingBox,
            "extras"  : "url_m",
            "nojsoncallback" : "1",
            "per_page" : "\(VTConstants.Flickr.MaxPhotos)",
            "page"  : "\(randomPage)"
        ]
        
        viewController.showActivityIndicatory()
        
        FlickrHandler.shared().request(parameters: parameters, completionHandler: { data, error in
            
            viewController.hideActivityIndicator()
            
            guard error == nil else {
                Util.showAlert(for: error?.localizedDescription ?? "Empty Description", in: viewController)
                return
            }
            
            guard let data = data else {
                Util.showAlert(for: "No data returned from server.", in: viewController)
                return
            }
            
            let dictionaryResult = data as! VTDictionary
            
            if let photos = FlickrPhoto.getPhotosFrom(response: dictionaryResult) {
                performUIUpdatesOnMain {
                    onCompletion(photos)
                }
            } else {
                Util.showAlert(for: "Cannot get photos from response.", in: viewController)
            }
        })
        
    }
}
