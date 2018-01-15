//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Vladimir Espinola on 1/14/18.
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
    @NSManaged public var pin: Pin?

}
