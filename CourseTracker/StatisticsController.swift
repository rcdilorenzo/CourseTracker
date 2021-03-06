//
//  StatisticsController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/15/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import CoreData

let notificationCenter = NSNotificationCenter.defaultCenter()

enum AgeRangeCuttoff {
    case Under
    case AtAndOver
}


class StatisticsController: UIViewController {
    @IBOutlet weak var noStatsLabel: UILabel!
    @IBOutlet weak var teamStatsTable: UITableView!
    @IBOutlet weak var firstRunnerStatsTable: UITableView!
    @IBOutlet weak var secondRunenrStatsTable: UITableView!
    var teamStatsDelegate: TeamStatsDelegate?
    var firstRangeStatsDelegate: RunnerAgeRangeStatsDelegate?
    var secondRangeStatsDelegate: RunnerAgeRangeStatsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamStatsDelegate = TeamStatsDelegate(table: teamStatsTable)
        firstRangeStatsDelegate = RunnerAgeRangeStatsDelegate(table: firstRunnerStatsTable, cuttoffAge: 13, rangeType: AgeRangeCuttoff.Under)
        secondRangeStatsDelegate = RunnerAgeRangeStatsDelegate(table: secondRunenrStatsTable, cuttoffAge: 13, rangeType: AgeRangeCuttoff.AtAndOver)
    }
}

class TeamStatsDelegate: NSObject, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    let cellID = "default"
    let fetchedResultsController: NSFetchedResultsController
    let tableView: UITableView
    
    init(table: UITableView) {
        let fetchRequest = Team.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Team.defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
        tableView = table
        super.init()
        notificationCenter.addObserver(self, selector: "reloadData", name:NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        for team in fetchedResultsController.fetchedObjects as! [Team] {
            team.updateScore()
        }
        table.delegate = self
        table.dataSource = self
        table.reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TeamRankCell
        cell.selectionStyle = .None
        let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
        if let name = team.name {
            cell.titleLabel.text = "\(indexPath.row + 1). \(name)"
        } else {
            cell.titleLabel.text = ""
        }
        cell.subtitleLabel.text = "\(team.runners.count) Runner(s)"
        cell.detailLabel.text = team.score == 0 || team.score == Double.infinity ? "" : "\(formatTimeInSec(NSTimeInterval(team.score)))"
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        reloadData()
    }
}


class RunnerAgeRangeStatsDelegate: NSObject, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    let cellID = "default"
    var cuttoffAge: Int
    var rangeType: AgeRangeCuttoff
    let tableView: UITableView
    let fetchedResultsController: NSFetchedResultsController
    let limit = 30
    
    init(table: UITableView, cuttoffAge: Int, rangeType: AgeRangeCuttoff) {
        self.cuttoffAge = cuttoffAge
        self.rangeType = rangeType
        let fetchRequest = Runner.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        switch rangeType {
            case AgeRangeCuttoff.Under:
                fetchRequest.predicate = NSPredicate(format: "age < \(cuttoffAge)")
            case AgeRangeCuttoff.AtAndOver:
                fetchRequest.predicate = NSPredicate(format: "age >= \(cuttoffAge)")
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Runner.defaultContext(), sectionNameKeyPath: nil, cacheName: "stats")
        tableView = table
        super.init()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        notificationCenter.addObserver(self, selector: "reloadData:", name:NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        table.delegate = self
        table.dataSource = self
        table.reloadData()
    }
    
    func reloadData(notification: NSNotification?) {
        if notification != nil {
            fetchedResultsController.performFetch(nil)
        }
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return min(sectionInfo.numberOfObjects, limit)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TeamRankCell
        cell.selectionStyle = .None
        let runner = (fetchedResultsController.fetchedObjects! as! [Runner]).sorted({ $0.fastestRunTime() < $1.fastestRunTime() })[indexPath.row]
        cell.titleLabel.text = runner.firstName != nil && runner.lastName != nil ? "\(indexPath.row + 1). \(runner.name())" : ""
        cell.subtitleLabel.text = runner.fastestRun() == nil ? "" : "Run at \(runner.fastestRun()!.timeDescription())"
        cell.detailLabel.text = runner.fastestRun() == nil ? "" : "\(formatTimeInSec(runner.fastestRunTime()))"
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}
