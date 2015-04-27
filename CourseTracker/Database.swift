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
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        request.fetchLimit = 1
        let context = self.defaultContext()
        return context.executeFetchRequest(request)?.first as? T
    }
    
    public class func entityName() -> String {
        return self.entityNameForClass(self)
    }
    
    public class func entityNameForClass(theClass: NSManagedObject.Type) -> String {
        return NSStringFromClass(theClass).componentsSeparatedByString(".").last!
    }
    
    public class func entityDescription() -> NSEntityDescription {
        return NSEntityDescription.entityForName(entityName(), inManagedObjectContext: defaultContext())!
    }
    
    /*
    * Usage pattern is as follows:
    *
    * let instanceName: ClassName = ClassName.newObjectInContext(managedObjectContext)
    */
    public class func newObjectInContext<T: NSManagedObject>(context: NSManagedObjectContext) -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: context) as! T
    }
    
    public class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: self.entityName())
    }
}