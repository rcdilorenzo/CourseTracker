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
import Dollar

protocol RunnerSearchDelegate {
    func runnerSearch(searchController: RunnerTableController, didSelectRunner runner: Runner, fromCell cell: UITableViewCell)
    func runnerSearchSelectedCreate(searchController: RunnerTableController)
}

class RunnerTableController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    let cellID = "subtitle"
    let alternateCellID = "basic"
    var showNewRunnerCell = true
    var allowSelectionForRun = false
    var selectedRunners = [Runner]()
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
            if navigation.navigationBar.topItem!.rightBarButtonItem == nil {
                navigation.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
            }
        }
    }
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return showNewRunnerCell ? fetchedResultsController!.sections!.count + 1 : fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNewRunnerCellSection(section) {
            return 1
        } else {
            let section = fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isNewRunnerCellSection(indexPath.section) {
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
            cell.accessoryType = contains(selectedRunners, runner) ? .Checkmark : .None
            cell.textLabel!.text = runner.name()
            cell.detailTextLabel!.text = "\(runner.age!) year old"
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController!.active = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isNewRunnerCellSection(indexPath.section) {
            searchDelegate?.runnerSearchSelectedCreate(self)
        } else if allowSelectionForRun {
            let runner = fetchedResultsController!.objectAtIndexPath(indexPath) as! Runner
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = .Checkmark
            if contains(selectedRunners, runner) {
                selectedRunners = $.pull(selectedRunners, values: runner)
            } else {
                selectedRunners += [runner]
            }
            refreshData(searchController!.searchBar.text)
        } else {
            let runner = fetchedResultsController!.objectAtIndexPath(indexPath) as! Runner
            searchDelegate?.runnerSearch(self, didSelectRunner: runner, fromCell: tableView.cellForRowAtIndexPath(indexPath)!)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isNewRunnerCellSection(section) {
            return nil
        } else {
            let section = fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
            return section.name
        }
    }
    
    func isNewRunnerCellSection(section: Int) -> Bool {
        return showNewRunnerCell && section == fetchedResultsController!.sections!.count
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
        let filterPredicate = NSPredicate(format: "(firstName contains[cd] %@) OR (lastName contains[cd] %@)", searchText, searchText)
        if selectedRunners.isEmpty {
            fetchRequest.predicate = searchText.isEmpty ? nil : filterPredicate
        } else {
            let teamPredicate = NSPredicate(format: "team = %@", selectedRunners.first!.team!)
            fetchRequest.predicate = searchText.isEmpty ? teamPredicate : NSCompoundPredicate(type: .AndPredicateType, subpredicates: [filterPredicate, teamPredicate])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Runner.defaultContext(), sectionNameKeyPath: "team.name", cacheName: nil)
        fetchedResultsController!.delegate = self
        fetchedResultsController!.performFetch(nil)
        tableView.reloadData()
    }
}
