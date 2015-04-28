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
    
    public init(name: String!, details: String?) {
        super.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.name = name
        self.details = details
    }
    
    public func setCurrent() -> Course {
        userDefaults.setValue(name, forKey: courseDefaultKey)
        userDefaults.synchronize()
        return self
    }
    
    public class func current() -> Course? {
        if let name = userDefaults.valueForKey(courseDefaultKey) as? String {
            return findFirstByAttribute("name", value: name)
        } else {
            return nil
        }
    }

}
