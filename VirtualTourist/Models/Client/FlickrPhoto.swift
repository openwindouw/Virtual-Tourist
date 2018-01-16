//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by user on 1/7/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

struct FlickrPhoto {
    var url: String?
    var image: UIImage?
    
    init(with dictionary: VTDictionary) {
        url = dictionary["url_m"] as? String
    }
}

extension FlickrPhoto {
    static func photosFromResults(_ results: [VTDictionary]) -> [FlickrPhoto] {
        
        var photos: [FlickrPhoto] = []
        
        for result in results {
            photos.append(FlickrPhoto(with: result))
        }
        
        return photos
    }
    
    static func getPhotosFrom(response: VTDictionary) -> [FlickrPhoto]? {
        
        guard let photosDictionary = response["photos"] as? VTDictionary, let photoArray = photosDictionary["photo"] as? [VTDictionary] else {
            return nil
        }
        
        return photosFromResults(photoArray)
    }
}

extension FlickrPhoto: Equatable {}

func ==(lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
    return lhs.url == rhs.url
}
