//
//  EditRunnerController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/4/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit

protocol ModalPresentControllerDelegate {
    func controllerDidDismiss(controller: UIViewController)
}

class NewRunnerController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let context = Runner.defaultContext()
    var runner: Runner?
    var delegate: ModalPresentControllerDelegate?
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var agePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.tintColor = primaryColor()
        firstNameField.addTarget(self, action: "firstNameChanged", forControlEvents: UIControlEvents.EditingChanged)
        lastNameField.addTarget(self, action: "lastNameChanged", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        context.beginTransaction()
        runner = Runner()
        runner!.team = Team.forRunner(runner!, inCourse: Course.current()!)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        context.undoTransaction()
        dismissViewControllerAnimated(true, completion: {
            self.delegate?.controllerDidDismiss(self)
        })
    }
    
    @IBAction func done(sender: AnyObject) {
        runner!.validate { (success, error) in
            if success {
                self.context.endTransactions()
                self.context.save()
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.controllerDidDismiss(self)
                })
            } else {
                let alertController = UIAlertController(title: "Create Runner Error", message: error!, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func firstNameChanged() {
        runner!.firstName = firstNameField.text
    }
    
    func lastNameChanged() {
        runner!.lastName = lastNameField.text
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "\(row + 2)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        runner!.age = NSNumber(integer: row+2)
    }
}
