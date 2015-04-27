//
//  Object.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

extension NSManagedObjectContext {
    func executeFetchRequest(request: NSFetchRequest) -> [NSManagedObject]? {
        var error : NSError? = nil
        let objects = executeFetchRequest(request, error: &error)
        if error != nil {
            println("Fetch error: \(error)")
        }
        return objects as! [NSManagedObject]?
    }
}

public extension NSManagedObject {
    public class func defaultContext() -> NSManagedObjectContext {
        return delegate.managedObjectContext!
    }
    
    public class func findFirstByAttribute<T>(attribute: String, value: AnyObject) -> T? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        request.fetchLimit = 1
        let context = defaultContext()
        return context.executeFetchRequest(request)?.first as? T
    }
    
    public class func entityName() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public class func entityDescription() -> NSEntityDescription {
        return NSEntityDescription.entityForName(entityName(), inManagedObjectContext: defaultContext())!
    }
    
    public class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: self.entityName())
    }
}