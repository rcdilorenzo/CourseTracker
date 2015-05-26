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
    var saveButton: UIBarButtonItem?
    var hideButton: UIBarButtonItem?
    @IBOutlet weak var mainViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    lazy var timeIntervalFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "mm:ss.SSS"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigation = navigationController {
            navigation.navigationBar.barTintColor = secondaryColor()
            navigation.navigationBar.tintColor = primaryColor()
            navigation.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
            navigation.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            saveButton = navigation.navigationBar.topItem!.rightBarButtonItem!
            saveButton!.enabled = false
            hideButton = UIBarButtonItem(title: "Hide  ", style: UIBarButtonItemStyle.Done, target: self, action: "hideController")
            hideButton!.enabled = false
            navigation.navigationBar.topItem!.rightBarButtonItems = [saveButton!, hideButton!]
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideTextField"))
        durationField.addTarget(self, action: "textValueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        mainViewLeftConstraint.constant = UIInterfaceOrientationIsLandscape(interfaceOrientation) ? defaultTableWidth : 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if run != nil {
            startButtonPressed(startButton)
        } else {
            run = Run(runners: runners)
            durationField.text = formatTimeInSec(0)
            stopButton.hidden = true
        }
    }
    
    func hideTextField() {
        view.endEditing(true)
    }
    
    func textValueChanged(sender: UITextField) {
        hideButton?.enabled = false
        if let currentDate = timeIntervalFormatter.dateFromString(sender.text) {
            saveButton?.enabled = true
            sender.tintColor = nil
            run!.start = NSDate()
            run!.timeInterval = currentDate.timeIntervalSince1970
        } else {
            saveButton?.enabled = false
            sender.tintColor = UIColor.redColor()
        }
    }
    
    func hideController() {
        hideTextField()
        context.save()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        hideTextField()
        if timer != nil && timer!.valid {
            stopButtonPressed(nil)
        }
        if let existingRun = run {
            context.deleteObject(existingRun)
            context.save()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        hideTextField()
        if timer != nil && timer!.valid {
            stopButtonPressed(nil)
        }
        let team = (run!.runners.anyObject() as! Runner).team!
        let duplicateRuns = Run.fromRunners(run!.runners.allObjects as! [Runner])
        Run.deleteAllButFastestRun(duplicateRuns)
        team.updateScore()
        context.save()
        dismissViewControllerAnimated(true, completion: nil)
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
        saveButton?.enabled = true
        hideButton?.enabled = true
        sender.hidden = true
        durationField.userInteractionEnabled = false
        stopButton.hidden = false
        if !run!.running {
            run!.startRun()
        }
        updateTimecode()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 30.0, target: self, selector: "updateTimecode", userInfo: nil, repeats: true)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton?) {
        run!.stopRun()
        sender?.removeTarget(self, action: "stopButtonPressed:", forControlEvents: .TouchUpInside)
        sender?.addTarget(self, action: "resetButtonPressed:", forControlEvents: .TouchUpInside)
        sender?.setTitle("Reset", forState: .Normal)
        sender?.backgroundColor = primaryColor()
        timer!.invalidate()
        durationField.userInteractionEnabled = true
    }
    
    func resetButtonPressed(sender: UIButton) {
        sender.removeTarget(self, action: "resetButtonPressed:", forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: "stopButtonPressed:", forControlEvents: .TouchUpInside)
        sender.setTitle("Stop", forState: .Normal)
        sender.backgroundColor = UIColor.redColor()
        startButtonPressed(sender)
    }
    
    func updateTimecode() {
        if let start = run?.start {
            durationField.text = formatTimeInSec(run!.start!.timeIntervalSinceNow * -1)
        }
    }
}