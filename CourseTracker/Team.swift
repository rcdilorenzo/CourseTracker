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

public class Team: NSManagedObject {

    @NSManaged var color: AnyObject
    @NSManaged var name: String
    @NSManaged var course: Course
    @NSManaged var runners: NSSet
    
    public convenience init(name: String, color: String) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.name = name
        self.color = color
    }
    
    public func runs() -> [Run] {
        var runs: Array<Run> = []
        for runner in runners.allObjects as! [Runner] {
            runs += runner.runs.allObjects as! [Run]
        }
        return $.uniq(runs, by: { $0.objectID })
    }

}
