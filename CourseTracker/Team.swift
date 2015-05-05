//
//  Team.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData
import Dollar
import UIKit

public class Team: NSManagedObject {

    @NSManaged public var color: UIColor?
    @NSManaged public var name: String?
    @NSManaged var course: Course
    @NSManaged var runners: NSSet
    
    public convenience init(course: Course) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.course = course
    }
    
    public convenience init(name: String, color: UIColor) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.name = name
        self.color = color
    }
    
    public class func byName(name: String) -> Team? {
        return findFirstByAttribute("name", value: name)
    }
    
    public func runs() -> [Run] {
        var runs: Array<Run> = []
        for runner in runners.allObjects as! [Runner] {
            runs += runner.runs.allObjects as! [Run]
        }
        return $.uniq(runs, by: { $0.objectID })
    }

}
