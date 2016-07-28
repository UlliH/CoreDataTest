//
//  DetailViewController.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 07.01.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate {
    
    // managedObjectContext
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
     // current Scope
    lazy var currentScope: DetailSearchScope! = DetailSearchScope.searchScopeKat
    // aktuelle Kategorie
    var kategorie: Kategorien!
    // aktuelles Detail
    var detail: Details!
    // aktuell gewählter Satz
    var selectedIndexPath: NSIndexPath!
    // gefilterte  Details
    lazy var filteredDetails = [Details]()
    // gefiltert?
    lazy var isFiltered = false
    //  Änderung vorhanden?
    lazy var recordUpdated = false
    // versteckt?
    var isDisappeared = false
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    // Zurück merken
    var saveBack: UIBarButtonItem! = nil
    // Scope merken
    lazy var oldScope: DetailSearchScope = DetailSearchScope.searchScopeKat
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Kategorie ermitteln
        if kategorie == nil {
            kategorie = findKategorie(0)
        }
        
        // Config
        self.title = kategorie.name
        setupNavigationBar()
        
        // SearchController aufsetzen
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.tintColor = UIColor.blueColor()
        
        searchController.searchBar.scopeButtonTitles = [self.kategorie.name!, "alle"]
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        searchController.searchBar.setValue("Done", forKey:"_cancelButtonText")
        searchController.searchBar.placeholder = "Find in " + kategorie.name!
        
        let searchBar = searchController.searchBar
        let scopeText = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let scope : DetailSearchScope = scopeText == "all" ? DetailSearchScope.searchScopeAll : DetailSearchScope.searchScopeKat
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        self.saveBack = self.navigationItem.leftBarButtonItem!
    }
    
    deinit {
        self.kategorie = nil
        self.searchController.loadViewIfNeeded()    // Bug iOS 9?
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var duration = 0.0

        if !self.isDisappeared {
        } else if !self.recordUpdated {
            duration = 0.5
        } else if self.selectedIndexPath != nil {
            duration = 0.7
        }

        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in self.tableView.selectRowAtIndexPath(self.selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
          }, completion: { finished in
             self.tableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            if self.recordUpdated {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            }
            self.tableView.reloadData()
            self.selectedIndexPath = nil
        })
        // preferredContentSizeChanged
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.onContentSizeChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object:nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.isDisappeared = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - NavigationBar aufsetzen
    
    func setupNavigationBar() {
        let workButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.toggleEditing))
        navigationItem.rightBarButtonItem = workButton
        navigationItem.hidesBackButton = true
        if self.fetchedResultsController.sections!.count == 0 {
            self.toggleEditing()
        }
    }
    
    // MARK: - UIBarButtonItem Callbacks
    
    func toggleEditing() {
        hideKeyboard()
        self.showAlert((self))
    }
    
    // MARK: - Segue ausführen
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailDisplay" {
            guard let detailViewController = segue.destinationViewController as? DetailDisplayController else {
                return }
            detailViewController.kategorie = self.kategorie
            detailViewController.detail = self.detail
        }
    }
     
    // MARK: - TableView Callbacks
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !self.isFiltered {
            return self.fetchedResultsController.sections!.count
        } else {
            return 1;
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFiltered{
            let sectionInfo = self.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return filteredDetails.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> DetailCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DetailCell") as! DetailCell
        if !isFiltered{
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Details
            configureCell(cell, atIndexPath: indexPath, object: object)
        } else {
            let object = filteredDetails[indexPath.row] as Details!
            self.configureCell(cell, atIndexPath: indexPath, object: object)
        }
        
        return cell
    }
    
    override func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        let lineHeight: CGFloat = 18 * 2.9

        return lineHeight;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if self.isFiltered {
            self.detail = filteredDetails[indexPath.row]
        } else {
            self.detail = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Details
        }
        return indexPath
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let message = "should this be deleted?"
            let title = "Delete"
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
                let detail: Details
                if self.isFiltered {
                    detail = self.filteredDetails[indexPath.row]
                    self.filteredDetails.removeAtIndex(indexPath.row)
                } else {
                    detail = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Details
                }

                self.managedObjectContext.deleteObject(detail)
                do {
                    try self.managedObjectContext.save()
                    try self.fetchedResultsController.performFetch()

                } catch let error as NSError {
                    NSLog("Unresolved error DetailViewController.performFetch() \(error)")
                }
                self.recordUpdated = true
                self.tableView.reloadData()
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
 
    // MARK: - TableView versorgen
    
    func configureCell(cell: DetailCell, atIndexPath indexPath: NSIndexPath, object: Details) {
        if object.kategorie == nil {
            return
        }
        cell.showAll = (currentScope == DetailSearchScope.searchScopeAll)
        cell.lblGruppe!.text = object.name
        cell.lblTelefon.text = object.telefon
    }

    // MARK: - UISearchBarDelegate functions
    
    //  Abbruch
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isFiltered = false
        let scope : DetailSearchScope = DetailSearchScope.searchScopeKat
        filterContentForSearchText("", scope: scope)
        self.searchController.searchBar.selectedScopeButtonIndex = 0
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchResultsUpdating
    func filterContentForSearchText(searchText: String, scope: DetailSearchScope! = .searchScopeKat) {
        if self.editing && self.searchController.searchBar.scopeButtonTitles?.count > 1{
            self.searchController.searchBar.scopeButtonTitles?.removeAll()
        }
        
        if searchText.isEmpty && self.oldScope != .searchScopeAll && (scope == nil || scope != .searchScopeAll) {
            return
        }
        if scope != nil {
            self.oldScope = scope
        }
        self.isFiltered = false
        var results = [Details]()
        // Kategorie (sonst sind es "alle" -> kein weiterer Filter)
        self.currentScope = scope
        let text = currentScope == DetailSearchScope.searchScopeKat ? "Find in " + kategorie.name! : "Find"
        searchController.searchBar.placeholder = text
        
        // Scope mit Predicate checken
        if currentScope == DetailSearchScope.searchScopeKat {
            if !searchText.isEmpty {
                let predicate:NSPredicate = buildSearchString(searchText)
                self.searchFetchRequest.predicate = predicate
            } else {
                self.searchFetchRequest.predicate = nil
            }
            results = try! managedObjectContext.executeFetchRequest(self.searchFetchRequest) as! [Details]
            results = results.filter { $0.kategorie == self.kategorie }
        } else if !searchText.isEmpty && currentScope == DetailSearchScope.searchScopeAll {
            let predicate:NSPredicate = buildSearchString(searchText)
            self.searchFetchRequest.predicate = predicate
            results = (try! managedObjectContext.executeFetchRequest(self.searchFetchRequest)) as! [Details]
        } else if searchText.isEmpty && currentScope == DetailSearchScope.searchScopeAll  {
            results = (try! managedObjectContext.executeFetchRequest(self.searchFetchRequest)) as! [Details]
        }
        filteredDetails = results
        self.isFiltered = true
        self.tableView.reloadData()
    }
   
    // Suchbegriff zusammenstellen
    func buildSearchString(searchString:String) -> NSPredicate {
        let predicate = NSPredicate(format: "name contains[cd] %@", searchString)
        return predicate
    }
    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Details")
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format:"kategorie == %@", self.kategorie)
        
        let fetchResult = NSFetchedResultsController(fetchRequest:fetchRequest,
                                              managedObjectContext:self.managedObjectContext,
                                              sectionNameKeyPath:nil,
                                              cacheName:nil)
        fetchResult.delegate = self
        
        do {
            try fetchResult.performFetch()
        } catch {
            print("Unresolved error \(error)")
            fatalError("Aborting with unresolved error")
        }
        return fetchResult
    }()

    // separater FetchRequest
    var searchFetchRequest:NSFetchRequest{
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Details", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
         return fetchRequest
    }
    
    // MARK: - preferredContentSizeChanged
    
    func onContentSizeChange(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    // MARK: - others
    
    func showAlert(sender: AnyObject) {
        let title = "Ino"
        let message = "not realized here"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
 }

extension DetailViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope : DetailSearchScope = selectedScope == 1 ? DetailSearchScope.searchScopeAll : DetailSearchScope.searchScopeKat
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

extension DetailViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if searchBar.scopeButtonTitles?.count > 0 {
            let scopeText = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            let scope : DetailSearchScope = scopeText == "alle" ? DetailSearchScope.searchScopeAll : DetailSearchScope.searchScopeKat
            filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        } else {
            filterContentForSearchText(searchController.searchBar.text!, scope: nil)
        }
}
}

// MARK: - DetailSearchScope

enum DetailSearchScope {
    case searchScopeKat, searchScopeAll
}