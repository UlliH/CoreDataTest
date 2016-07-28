//
//  CoreDataSeed.swift
//  Bibliothek
//
//  Created by Ulrich Heinelt on 29.12.15.
//  Copyright © 2015 Ulrich Heinelt. All rights reserved.
//

import CoreData

class CoreDataSeed {
    
    let context:NSManagedObjectContext
    let psc:NSPersistentStoreCoordinator
    let model:NSManagedObjectModel
    var store:NSPersistentStore?
    
    init() {
        
        let modelName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String!
        
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource(modelName, withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        let documentsURL = applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent(modelName + ".sqlite")
        let seededDatabaseURL = bundle.URLForResource(modelName,withExtension: "sqlite")
        
        var fileManagerError:NSError? = nil
        do {
            try NSFileManager.defaultManager().copyItemAtURL(seededDatabaseURL!, toURL: storeURL)
            fileManagerError = nil
            let seededSHMURL = bundle.URLForResource(modelName, withExtension: "sqlite-shm")
            let shmURL = documentsURL.URLByAppendingPathComponent(modelName + ".sqlite-shm")
            
            do {
                try NSFileManager.defaultManager().copyItemAtURL(seededSHMURL!, toURL: shmURL)
            } catch let error as NSError {
                fileManagerError = error
                NSLog("Error seeding Core Data: %@", fileManagerError!)
                abort()
            }
            
            fileManagerError = nil
            let walURL = documentsURL.URLByAppendingPathComponent(modelName + ".sqlite-wal")
            let seededWALURL = bundle.URLForResource(modelName,withExtension: "sqlite-wal")
            
            do {
                try NSFileManager.defaultManager().copyItemAtURL(seededWALURL!, toURL: walURL)
            } catch let error as NSError {
                fileManagerError = error
                NSLog("Error seeding Core Data: %@", fileManagerError!)
                abort()
            }
            print("Seeded Core Data")
        } catch let error as NSError {
            fileManagerError = error
        }
        
        var error: NSError? = nil
        let options = [NSInferMappingModelAutomaticallyOption:true, NSMigratePersistentStoresAutomaticallyOption:true]
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch let error1 as NSError {
            error = error1
            store = nil
        }
        if store == nil {
            NSLog("Error adding persistent store: %@", error!)
            abort()
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls =
        fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
}

