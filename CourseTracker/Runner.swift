//
//  Runner.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

public class Runner: NSManagedObject {

    @NSManaged var age: NSNumber
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var team: Team
    @NSManaged var runs: NSSet
    
    public convenience init(firstName: String!, lastName: String!, age: Int, team: Team) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.team = team
    }
    
    public func addRun(run: Run) {
        let _runs = mutableSetValueForKey("runs")
        _runs.addObject(run)
    }

}
