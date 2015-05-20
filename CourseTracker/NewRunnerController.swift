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

class NewRunnerController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    let context = Runner.defaultContext()
    var runner: Runner?
    var delegate: ModalPresentControllerDelegate?
    var teams = [Team]()
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var agePicker: UIPickerView!
    @IBOutlet weak var teamPicker: UIPickerView!
    
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
        teams = Course.current()!.teams.allObjects as! [Team]
    }
    
    @IBAction func cancel(sender: AnyObject) {
        context.undoTransaction()
        dismissViewControllerAnimated(true, completion: {
            self.delegate?.controllerDidDismiss(self)
        })
    }
    
    @IBAction func done(sender: AnyObject?) {
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            lastNameField.becomeFirstResponder()
        default:
            done(nil)
        }
        return true
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
        return pickerView == agePicker ? 100 : teams.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerView == agePicker ? "\(row + 2)" : teams[row].name!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePicker {
            runner!.age = NSNumber(integer: row+2)
            runner!.team = nil
            runner!.team = Team.forRunner(runner!, inCourse: Course.current()!)
            teamPicker.selectRow((teams as NSArray).indexOfObject(runner!.team!), inComponent: 0, animated: true)
        } else {
            runner!.team = teams[row]
        }
    }
}
