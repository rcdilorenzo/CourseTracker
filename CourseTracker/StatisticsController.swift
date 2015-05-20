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
        let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
        cell.titleLabel.text = team.name
        cell.subtitleLabel.text = "\(team.runners.count) Runner(s)"
        cell.detailLabel.text = team.score != Double.infinity ? "\(formatTimeInSec(NSTimeInterval(team.score)))" : ""
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        reloadData()
    }
}


class RunnerAgeRangeStatsDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    let cellID = "default"
    var cuttoffAge: Int
    var rangeType: AgeRangeCuttoff
    let tableView: UITableView
    
    init(table: UITableView, cuttoffAge: Int, rangeType: AgeRangeCuttoff) {
        self.cuttoffAge = cuttoffAge
        self.rangeType = rangeType
        tableView = table
        super.init()
        notificationCenter.addObserver(self, selector: "reloadData", name:NSManagedObjectContextObjectsDidChangeNotification, object: nil)
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TeamRankCell
        return cell
    }
}
