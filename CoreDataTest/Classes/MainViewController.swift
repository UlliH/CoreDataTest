///
//  MainViewController.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 03.01.2016.
//  Copyright (c) 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    // Grundlage für neuen Daten bei leerer "DB"
    var imageItems: [String]! = []
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

    weak var kategorie: Kategorien!
    weak var selectedIndexPath:NSIndexPath!
    weak var saveKat: Kategorien!
    
    lazy var currentRow = 0

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.initImageItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // preferredContentSizeChanged
   
        self.tableView.selectRowAtIndexPath(self.selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        let duration = self.selectedIndexPath != nil ? 0.3  : 0.0
        self.selectedIndexPath = nil
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            if self.currentRow == -1 {
                self.currentRow = 0
            }
            self.tableView.reloadData()
        })

    }
 
    deinit {
        kategorie = nil
        imageItems = nil
        saveKat = nil
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Unresolved error \(error)")
        }
    }

    // MARK: - NavigationBar lifecycle
 
    func setupNavigationBar() {
        let aboutButton = UIButton(type: UIButtonType.Custom)
        aboutButton.frame = CGRectMake(0, 0, 25, 40)
        if let image  = UIImage(named: "about") {
            aboutButton.setImage(image, forState: .Normal)
        }
        aboutButton.addTarget(self, action: #selector(MainViewController.aboutTouched(_:)), forControlEvents:.TouchUpInside)
        let about = UIBarButtonItem(customView: aboutButton)
 
        let helpButton = UIButton(type: UIButtonType.Custom)
        helpButton.frame = CGRectMake(0, 0, 25, 40)
        if let image  = UIImage(named:  "help") {
            helpButton.setImage(image, forState: .Normal)
        }
        helpButton.addTarget(self, action: #selector(MainViewController.helpTouched(_:)), forControlEvents:.TouchUpInside)
        let help = UIBarButtonItem(customView: helpButton)
        navigationItem.rightBarButtonItems = [about, help]
    }

    // Hilfe
    func helpTouched(sender:UIButton!) {
        self.showMessage(self)
    }
    
    // About
    func aboutTouched(sender:UIButton!) {
        self.showMessage(self)
    }

    // MARK: - Table View Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> KategorieCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("KategorieCell", forIndexPath: indexPath) as! KategorieCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    // Cell konfigurieren
    func configureCell(cell: KategorieCell, atIndexPath indexPath: NSIndexPath) {
        let data = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.nameField!.text = data.valueForKey("name")!.description
        self.kategorie = self.fetchedResultsController.fetchedObjects![indexPath.row] as! Kategorien
        let imageName = data.valueForKey("imagename")!.description
        if imageName != "" {
            let image = UIImage(named: imageName)
            cell.imageButton.setImage(image, forState: .Normal)
        }
        let counter = self.countEntries(self.kategorie)
        cell.tag = counter == "0" ? 0 : 1
        cell.imageButton.badgeText = counter
        
        // Font
        cell.nameField!.font = UIFont.preferredFontForTextStylWithScaleAndWidth(UIFontTextStyleSubheadline, scaleFactor: 1.2, weigth: UIFontWeightMedium)
    }

    // MARK: - Segue lifecycle
    @IBAction func unwindDetail(segue: UIStoryboardSegue) {
        // cellForRowAtIndexPath mit configureCell (badgeCounter) aufrufen
        self.tableView.reloadData()
    }
 
    // MARK: - Segue lifecycle

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
            guard let controller = segue.destinationViewController as? DetailViewController else {
                return }
            controller.kategorie = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Kategorien
            self.saveKat = controller.kategorie
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        let tag = sender.tag == nil ? 0 : sender.tag
        // bei Fensterwechsel (Setup) prüfen, ob die DetailView im Edit ist.
        if (identifier.length == 0 || tag! == 1) && identifier != "failedAction" {
            return true
        }
        return true
    }
 
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Kategorien")
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key:"order", ascending:true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResult = NSFetchedResultsController(fetchRequest:fetchRequest,
                                                     managedObjectContext:self.managedObjectContext,
                                                     sectionNameKeyPath:nil,
                                                     cacheName:"root")
        fetchResult.delegate = self
        
        do {
            try fetchResult.performFetch()
        } catch {
            print("Unresolved error \(error)")
            fatalError("Aborting with unresolved error")
        }
        return fetchResult
    }()
    
    // MARK: - Counter versorgen
 
    private func countEntries(kategorie: Kategorien) -> String {
        var entityCount = 0
        let fetchRequest = NSFetchRequest(entityName: "Details")
        fetchRequest.predicate = NSPredicate(format:"kategorie = %@", kategorie)
        var error: NSError?
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        if (error != nil) {
            entityCount = 0
        } else {
            entityCount = count
        }
        let string = NSString(format: "%lu", entityCount)
        return string as String
    }

    // MARK: - Util
    @IBAction func showMessage(sender: AnyObject) {
        let title = "Info"
        let message = "not realized here"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // Bilder versorgen
    private func initImageItems() {
        let inputFile = NSBundle.mainBundle().pathForResource("pictures", ofType: "plist")
        let inputDataArray = NSArray(contentsOfFile: inputFile!)
        
        for inputItem in inputDataArray as! [Dictionary<String, String>] {
            let imageItem = ImageItem(dataDictionary: inputItem)
            //let name = inputItem.values.first
            imageItems.append(imageItem.itemImage)
        }
    }
 }

 