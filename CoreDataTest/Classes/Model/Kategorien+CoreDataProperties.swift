//
//  Kategorien+CoreDataProperties.swift
//  Bibliothek
//
//  Created by Ulrich Heinelt on 15.07.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Kategorien {

    @NSManaged var imagename: String?
    @NSManaged var katid: NSNumber?
    @NSManaged var name: String?
    @NSManaged var order: NSNumber?
    @NSManaged var details: Details?

}
