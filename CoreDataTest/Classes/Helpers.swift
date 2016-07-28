//
//  Helpers.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 08.01.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit
import CoreData

// aktuellen Kategorie ermitteln
func findKategorie(pos: Int) -> Kategorien? {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Kategorien", inManagedObjectContext: managedObjectContext)
    fetchRequest.entity = entity
    
    let sortDescriptor = NSSortDescriptor(key: "order", ascending: true, selector: #selector(NSNumber.compare(_:)))
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    do {
        let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Kategorien]
        return fetchedResults[pos]
    } catch let error as NSError {
        NSLog("Unresolved error \(error)")
    }
    return nil
}

func hideKeyboard() {
    UIApplication.sharedApplication().keyWindow?.endEditing(true)
}

func isRetina() -> Bool {
    return UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale)) && UIScreen.mainScreen().scale == 2.0
}

func extractPhoneNumber(phoneNumber: String) -> String {
    return phoneNumber.stringByReplacingOccurrencesOfString(
        "\\D", withString: "", options: .RegularExpressionSearch,
        range: phoneNumber.startIndex..<phoneNumber.endIndex)
}
