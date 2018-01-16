//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Vladimir Espinola on 1/14/18.
//  Copyright © 2018 Vladimir Espinola. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    // MARK: Initializer
    
    convenience init(data: NSData, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.image = data
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
