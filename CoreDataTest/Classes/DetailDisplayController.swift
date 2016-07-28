//
//  DetailDisplayController.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 01.03.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import CoreData
import UIKit
import MessageUI

class DetailDisplayController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var kategorie: Kategorien!
    var detail: Details! = nil
    lazy var currentEdit: UITextField! = nil
    // abgebrochen?
    lazy var isCanceled = false
    // Spalten aktiv
    var colsEnabled = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kategorie.name

        self.navigationItem.rightBarButtonItem = nil
        
        if self.colsEnabled {
            let saveButton = self.navigationItem.rightBarButtonItem
            saveButton!.enabled = false
        }
    }
    
    deinit {
        self.currentEdit = nil
        self.kategorie = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
   }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // preferredContentSizeChanged
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailDisplayController.onContentSizeChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.currentEdit = nil
     }

     // MARK: - Table View Callbacks
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> DetailColumnCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DisplayCell") as! DetailColumnCell
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Details
        configureCell(cell, atIndexPath: indexPath, withObject: object)

        return cell
    }
    
    override func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        let height:CGFloat = 300
        return height;
    }

    // MARK: - Table view data source extension
    
    // TableViewCell versorgen
    func configureCell(cell: DetailColumnCell, atIndexPath indexPath: NSIndexPath, withObject object:Details) {
        cell.txtName.text = object.name
        cell.txtTelefon.text = object.telefon
        cell.txtAddress.text = object.address
        cell.txtMail.text = object.mail
        cell.txtName.tag = 1
        cell.txtAddress.tag = 2
        cell.txtTelefon.tag = 3
        cell.txtMail.tag = 4
    }
    
    // MARK: - Steuerung
    
    @IBAction func close(sender: AnyObject) {
        self.performSegueWithIdentifier("closeDetail", sender: sender)
    }
  
    // MARK: - Fetched results controller

    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Details")
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResult = NSFetchedResultsController(fetchRequest:fetchRequest,
                                                     managedObjectContext:self.managedObjectContext,
                                                     sectionNameKeyPath:nil,
                                                     cacheName:nil)
        fetchRequest.predicate = NSPredicate(format: "detailid ==  %@", self.detail.detailid!)

        fetchResult.delegate = self
        
        do {
            try fetchResult.performFetch()
        } catch {
            print("Unresolved error \(error)")
            fatalError("Aborting with unresolved error")
        }
        return fetchResult
    }()
 
    func scrollTop() {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    // MARK: - preferredContentSizeChanged

    @IBAction func imageTapped(sender: AnyObject) {
        let title = "attention"
        let message = "not realized here"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onContentSizeChange(notification: NSNotification) {
        self.tableView.reloadData()
    }

}