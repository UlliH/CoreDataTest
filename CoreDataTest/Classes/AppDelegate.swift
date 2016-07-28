//
//  AppDelegate.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 01.01.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let coreSeed = CoreDataSeed()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let navigationController : UINavigationController
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad  {
            let splitViewController = window!.rootViewController as! UISplitViewController
            navigationController = splitViewController.viewControllers.last as! UINavigationController
            let splitDelegate = navigationController.topViewController as! UISplitViewControllerDelegate
            splitViewController.delegate = splitDelegate
        } else {
            navigationController = window!.rootViewController as! UINavigationController
        }
        
        if let window = self.window {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            UINavigationBar.appearance().barTintColor = UIColor(red: 0.465, green: 0.622, blue: 0.831, alpha: 1.0)
            window.tintColor = UIColor.blueColor()
        }
        #if DEBUG
            let documentURL : NSURL = try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            print(documentURL)
        #endif
        
        //insertTest()

        return true
    }
    
    func insertTest() {
        var entity =  NSEntityDescription.entityForName("Kategorien", inManagedObjectContext: managedObjectContext!)
        let request = NSFetchRequest()
        request.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "katid", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format:"katid == 1")
        var result: AnyObject?
        do {
            result = try managedObjectContext!.executeFetchRequest(request).last
        } catch let error as NSError {
            let error1 = error
            print("Could not save \(error1), \(error1.userInfo)")
        }
        
        entity =  NSEntityDescription.entityForName("Details", inManagedObjectContext: managedObjectContext!)
        let obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedObjectContext)
        obj.setValue(result, forKey: "kategorie")
        obj.setValue(12, forKey: "detailid")
        obj.setValue("Fitti Langhorst", forKey: "name")
        obj.setValue("05031-9513", forKey: "telefon")
        obj.setValue("Neustädter Str. ", forKey: "address")
        obj.setValue("fitti@docs.de", forKey: "mail")

        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            let error1 = error
            print("Could not save \(error1), \(error1.userInfo)")
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack (automatically generated)
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.heinelt.Visitenkarten" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    var applicationName: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String!
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let appName: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String!
        let modelURL = NSBundle.mainBundle().URLForResource(appName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let appName: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String!
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(appName + ".sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType:NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}

