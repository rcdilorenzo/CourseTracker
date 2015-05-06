//
//  ViewController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import FontAwesomeKit

class ViewController: UIViewController, RunnerSearchDelegate, ModalPresentControllerDelegate {

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
        let runnerController = storyboard!.instantiateViewControllerWithIdentifier("runnerController") as! RunnerTableController
        runnerController.searchDelegate = self
        let navigation = UINavigationController(rootViewController: runnerController)
        navigation.preferredContentSize = CGSizeMake(400, 800)
        navigation.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        navigationController?.presentViewController(navigation, animated: true, completion: nil)
    }

    func runnerSearch(searchController: RunnerTableController, didSelectRunner runner: Runner, fromCell cell: UITableViewCell) {
        println("Runner selected: \(runner.name())")
    }
    
    func runnerSearchSelectedCreate(searchController: RunnerTableController) {
        searchController.dismissViewControllerAnimated(true, completion: { () -> Void in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("newRunner") as! UINavigationController
            controller.preferredContentSize = CGSizeMake(320, 250)
            controller.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            (controller.topViewController as! NewRunnerController).delegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }


}

