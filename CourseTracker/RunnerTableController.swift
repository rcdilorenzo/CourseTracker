//
//  RunnerSearchTableController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/4/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import CoreData
import FontAwesomeKit

protocol RunnerSearchDelegate {
    func runnerSearch(searchController: RunnerTableController, didSelectRunner runner: Runner, fromCell cell: UITableViewCell)
    func runnerSearchSelectedCreate(searchController: RunnerTableController)
}

class RunnerTableController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    let cellID = "subtitle"
    let alternateCellID = "basic"
    var searchDelegate: RunnerSearchDelegate?
    var fetchedResultsController: NSFetchedResultsController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData("")
        searchController = UISearchController(searchResultsController: nil)
        searchController!.searchResultsUpdater = self
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = false
        searchController!.searchBar.delegate = self
        searchController!.searchBar.barTintColor = UIColor.groupTableViewBackgroundColor()
        searchController!.searchBar.tintColor = primaryColor()
        searchController!.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController!.searchBar
        definesPresentationContext = true
        
        if let navigation = navigationController {
            navigation.navigationBar.topItem?.title = "Runners"
            navigation.navigationBar.barTintColor = secondaryColor()
            navigation.navigationBar.tintColor = primaryColor()
            navigation.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
            navigation.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        }
    }
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController!.sections!.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < fetchedResultsController!.sections!.count {
            let section = fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
            return section.numberOfObjects
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isLastCell(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier(alternateCellID, forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel!.attributedText = NSAttributedString(string: "New Runner", attributes: [
                NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
                NSForegroundColorAttributeName: primaryColor()
            ])
            let plusIcon = FAKFontAwesome.plusIconWithSize(22)
            plusIcon.addAttribute(NSForegroundColorAttributeName, value: primaryColor())
            cell.accessoryView = UIImageView(image: plusIcon.imageWithSize(CGSizeMake(22, 22)))
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UITableViewCell
            let runner = fetchedResultsController!.objectAtIndexPath(indexPath) as! Runner
            cell.textLabel!.text = runner.name()
            cell.detailTextLabel!.text = "\(runner.age!) year old"
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController!.active = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isLastCell(indexPath) {
            searchDelegate?.runnerSearchSelectedCreate(self)
        } else {
            let runner = fetchedResultsController!.objectAtIndexPath(indexPath) as! Runner
            searchDelegate?.runnerSearch(self, didSelectRunner: runner, fromCell: tableView.cellForRowAtIndexPath(indexPath)!)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < fetchedResultsController!.sections!.count {
            let section = fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
            return section.name
        }
        return nil
    }
    
    func isLastCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let runner = fetchedResultsController!.objectAtIndexPath(indexPath) as! Runner
        let context = Runner.defaultContext()
        context.deleteObject(runner)
        context.save()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        refreshData(searchController.searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        refreshData(searchText)
    }
    
    func refreshData(searchText: String) {
        let fetchRequest = Runner.fetchRequest()
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "(firstName contains[cd] %@) OR (lastName contains[cd] %@)", searchText, searchText)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Runner.defaultContext(), sectionNameKeyPath: "team.name", cacheName: nil)
        fetchedResultsController!.delegate = self
        fetchedResultsController!.performFetch(nil)
        tableView.reloadData()
    }
}
