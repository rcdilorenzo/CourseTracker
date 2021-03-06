//
//  Course.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

let userDefaults = NSUserDefaults.standardUserDefaults()
let courseDefaultKey = "courseID"

public class Course: NSManagedObject {

    @NSManaged var details: String?
    @NSManaged var name: String!
    @NSManaged var teams: NSSet
    
    public convenience init(name: String!, details: String?) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.name = name
        self.details = details
    }
    
    public func setCurrent() -> Course {
        userDefaults.setValue(name, forKey: courseDefaultKey)
        userDefaults.synchronize()
        managedObjectContext!.save()
        return self
    }
    
    public class func current() -> Course? {
        if let name = userDefaults.valueForKey(courseDefaultKey) as? String {
            return findFirstByAttribute("name", value: name)
        } else {
            let request = fetchRequest()
            request.fetchLimit = 1
            if let course = defaultContext().executeFetchRequest(request)?.first as? Course {
                return course.setCurrent()
            }
            return nil
        }
    }
    
    public func averageAge() -> Double {
        let request = Runner.fetchRequest()
        request.predicate = NSPredicate(format: "(team in %@) AND (age > 0)", self.teams)
        request.propertiesToFetch = ["age"]
        let runners = managedObjectContext!.executeFetchRequest(request) as! [Runner]
        let ages = runners.map { $0.age!.doubleValue }
        return average(ages)
    }

}
