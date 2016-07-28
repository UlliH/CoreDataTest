//
//  Details+CoreDataProperties.swift
//  CoreDataTest
//
//  Created by Ulrich Heinelt on 20.07.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Details {

    @NSManaged var address: String?
    @NSManaged var mail: String?
    @NSManaged var name: String?
    @NSManaged var telefon: String?
    @NSManaged var detailid: NSNumber?
    @NSManaged var kategorie: Kategorien?

}
