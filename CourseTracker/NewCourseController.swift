//
//  NewCourseController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit

class NewCourseController : UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func createCourse(sender: AnyObject) {
        if textField.text.isEmpty {
            let alertController = UIAlertController(title: "Course Create Error", message: "A course requires a name.", preferredStyle: .Alert)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            Course(name: textField.text, details: nil).setCurrent()
            Course.defaultContext().save(nil)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
