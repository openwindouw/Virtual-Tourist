//
//  VTConstants.swift
//  VirtualTourist
//
//  Created by user on 1/5/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

struct VTConstants {
    struct Flickr {
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        static let MaxPhotos = 21
        static let MaxPage = 40
    }
    
    struct Metrics {
        static let CornerRadius: CGFloat = 6
    }
    
    struct UserDefaultsKeys {
        static let centerLatitude = "centerLatitude"
        static let centerLongitude = "centerLongitude"
        static let region = "region"
    }
}
