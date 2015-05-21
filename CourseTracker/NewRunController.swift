//
//  NewRunController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/5/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import Dollar

class NewRunController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let cellID = "subtitle"
    let defaultTableWidth = CGFloat(250)
    let context = Run.defaultContext()
    var runners = [Runner]()
    var run: Run?
    var timer: NSTimer?
    @IBOutlet weak var mainViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigation = navigationController {
            navigation.navigationBar.barTintColor = secondaryColor()
            navigation.navigationBar.tintColor = primaryColor()
            navigation.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
            navigation.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        }
        mainViewLeftConstraint.constant = UIInterfaceOrientationIsLandscape(interfaceOrientation) ? defaultTableWidth : 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        context.beginTransaction()
        run = Run(runners: runners)
        stopButton.hidden = true
        durationLabel.hidden = true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        context.undoTransaction()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        context.endTransactions()
        let duplicateRuns = Run.fromRunners(run!.runners.allObjects as! [Runner])
        Run.deleteAllButFastestRun(duplicateRuns)
        context.save()
        dismissViewControllerAnimated(true, completion: nil)
        (run!.runners.anyObject() as! Runner).team!.updateScore()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runners.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UITableViewCell
        let runner = runners[indexPath.row]
        cell.textLabel!.text = runner.name()
        cell.detailTextLabel!.text = runner.fastestRunDescription()
        return cell
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        mainViewLeftConstraint.constant = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? defaultTableWidth : 0
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        sender.hidden = true
        stopButton.hidden = false
        durationLabel.hidden = false
        run!.startRun()
        updateTimecode()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 30.0, target: self, selector: "updateTimecode", userInfo: nil, repeats: true)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        run!.stopRun()
        sender.removeTarget(self, action: "stopButtonPressed:", forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: "resetButtonPressed:", forControlEvents: .TouchUpInside)
        sender.setTitle("Reset", forState: .Normal)
        sender.backgroundColor = primaryColor()
        timer!.invalidate()
    }
    
    func resetButtonPressed(sender: UIButton) {
        sender.removeTarget(self, action: "resetButtonPressed:", forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: "stopButtonPressed:", forControlEvents: .TouchUpInside)
        sender.setTitle("Stop", forState: .Normal)
        sender.backgroundColor = UIColor.redColor()
        startButtonPressed(sender)
    }
    
    func updateTimecode() {
        durationLabel.text = formatTimeInSec(run!.start!.timeIntervalSinceNow * -1)
    }
}