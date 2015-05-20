//
//  ViewController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Dollar

class ViewController: UIViewController, RunnerSearchDelegate, ModalPresentControllerDelegate {
    var runnerController: RunnerTableController?

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBar = navigationController!.navigationBar
        let usersBarItem = UIBarButtonItem(image: FAKFontAwesome.usersIconWithSize(22).imageWithSize(CGSizeMake(22, 22)), style: UIBarButtonItemStyle.Plain, target: self, action: "showRunnerController")
        navigationBar.topItem!.rightBarButtonItems = [navigationBar.topItem!.rightBarButtonItem!, usersBarItem]
        navigationBar.tintColor = primaryColor()
        if let course = Course.current() {
            self.navigationItem.title = course.name
        } else {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("newCourse") as! NewCourseController
            presentViewController(controller, animated: false, completion: nil)
        }
    }
    
    func controllerDidDismiss(controller: UIViewController) {
        if controller as? NewRunnerController != nil {
            showRunnerController()
        }
    }
    
    func showRunnerController() {
        runnerController = storyboard!.instantiateViewControllerWithIdentifier("runnerController") as? RunnerTableController
        runnerController!.searchDelegate = self
        let navigation = UINavigationController(rootViewController: runnerController!)
        navigation.preferredContentSize = CGSizeMake(400, 800)
        navigation.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        navigationController?.presentViewController(navigation, animated: true, completion: nil)
    }
    
    @IBAction func showNewRunController() {
        runnerController = storyboard!.instantiateViewControllerWithIdentifier("runnerController") as? RunnerTableController
        runnerController!.showNewRunnerCell = false
        runnerController!.allowSelectionForRun = true
        runnerController!.searchDelegate = self
        let navigation = UINavigationController(rootViewController: runnerController!)
        navigation.preferredContentSize = CGSizeMake(400, 800)
        navigation.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let navigationItem = navigation.navigationBar.topItem!
        navigationItem.title = "New Run"
        navigationItem.prompt = "Choose runner(s)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelNewRun")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "newRunWithSelectedRunners")
        navigationItem.rightBarButtonItem!.enabled = false
        navigationController?.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func cancelNewRun() {
        runnerController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newRunWithSelectedRunners() {
        runnerController!.dismissViewControllerAnimated(true, completion: {
            let navigation = self.storyboard!.instantiateViewControllerWithIdentifier("newRunNavigation") as! UINavigationController
            let newRunController = navigation.topViewController as! NewRunController
            newRunController.runners = self.runnerController!.selectedRunners.sorted({ $0.firstName! < $1.firstName! })
            self.presentViewController(navigation, animated: true, completion: nil)
        })
    }
    

    func runnerSearch(searchController: RunnerTableController, didSelectRunner runner: Runner, fromCell cell: UITableViewCell) {
        if searchController.allowSelectionForRun {
            let topItem = searchController.navigationController!.navigationBar.topItem!
            let runners = searchController.selectedRunners
            topItem.rightBarButtonItem!.enabled = !runners.isEmpty
            if topItem.rightBarButtonItem!.enabled {
                let names = join(", ", runners.map({ $0.firstName! }))
                topItem.prompt = "Selected: \(names)"
            } else {
                topItem.prompt = "Choose runner(s)"
            }
        }
        println("Runner selected: \(runner.name())")
    }
    
    func runnerSearchSelectedCreate(searchController: RunnerTableController) {
        searchController.dismissViewControllerAnimated(true, completion: { () -> Void in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("newRunner") as! UINavigationController
            controller.preferredContentSize = CGSizeMake(400, 300)
            controller.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            (controller.topViewController as! NewRunnerController).delegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }


}

