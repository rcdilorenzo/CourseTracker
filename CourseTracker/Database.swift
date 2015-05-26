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
    
    func beginTransaction() {
        undoManager = NSUndoManager()
        undoManager!.beginUndoGrouping()
    }
    
    func endTransactions() {
        while undoManager?.groupingLevel > 0 {
            undoManager?.endUndoGrouping()
        }
    }
    
    func undoTransaction() {
        endTransactions()
        undoManager?.undo()
    }
    
    func save() -> Bool {
        var error: NSError? = nil
        let success = save(&error)
        if error != nil {
            println("Save error: \(error)")
        } else {
            println("Database saved.")
        }
        return success
    }
}

public extension NSManagedObject {
    class func deleteAll() {
        let context = defaultContext()
        let objects = context.executeFetchRequest(fetchRequest())!
        for object in objects {
            context.deleteObject(object)
        }
        context.save()
    }
    
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
    
    public class func findAllByAttribute(attribute: String, value: AnyObject) -> [NSManagedObject] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        let context = defaultContext()
        if let objects = context.executeFetchRequest(request) {
            return objects
        }
        return []
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