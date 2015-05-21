//
//  NewTeamController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/28/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import CoreData
import Dollar

class NewTeamController: UITableViewController, UITextFieldDelegate {
    var team: Team? = nil
    let context = Team.defaultContext()
    @IBOutlet weak var selectedColor: UIView!
    @IBOutlet var colorViews: [UIView]!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollEnabled = false
        preferredContentSize = CGSizeMake(320, 145)
        selectedColor.backgroundColor = UIColor.clearColor()
        selectedColor.layer.cornerRadius = selectedColor.frame.size.width / 2.0
        navigationController?.navigationBar.tintColor = primaryColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        context.beginTransaction()
        team = Team(course: Course.current()!)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        context.undoTransaction()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        context.endTransactions()
        if team!.name == nil || team!.color == nil {
            let alert = UIAlertController(title: "Team cannot be saved.", message: "Name and color are required.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else if context.save() {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(self.view)
        if let tappedView = view.hitTest(point, withEvent: nil) {
            if $.contains(colorViews, value: tappedView) {
                team!.color = tappedView.backgroundColor!
                selectedColor.backgroundColor = team!.color
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        team!.name = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return true
    }
}
