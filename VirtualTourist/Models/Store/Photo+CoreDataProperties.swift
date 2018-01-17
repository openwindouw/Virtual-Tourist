//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by user on 1/17/18.
//  Copyright © 2018 Vladimir Espinola. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
