//
//  LiveRunsController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/24/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import CoreData

class LiveRunsController: UITableViewController {
    var runs = [Run]()
    var timer: NSTimer?
    var popover: UIPopoverController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        popover?.popoverContentSize = CGSizeMake(300, CGFloat(min(tableView.visibleCells().count * 44, 10 * 44)))
        notificationCenter.addObserver(self, selector: "refreshData", name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        notificationCenter.removeObserver(self)
    }
    
    func refreshData() {
        let fetchRequest = Run.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "running == YES")
        runs = Run.defaultContext().executeFetchRequest(fetchRequest) as! [Run]
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "reloadTable", userInfo: nil, repeats: true)
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(runs.count, 1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if runs.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("noData") as! UITableViewCell
            cell.selectionStyle = .None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("default", forIndexPath: indexPath) as! TeamRankCell
            let run = runs[indexPath.row]
            cell.titleLabel.text = formatTimeInSec(-1 * run.start!.timeIntervalSinceNow)
            cell.subtitleLabel.text = run.runnerNames()
            cell.detailLabel.text = run.timeDescription()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !runs.isEmpty {
            let run = runs[indexPath.row]
            let navigationController = storyboard!.instantiateViewControllerWithIdentifier("newRunNavigation") as! UINavigationController
            let controller = navigationController.topViewController as! NewRunController
            controller.run = run
            controller.runners = run.runners.allObjects as! [Runner]
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
}
