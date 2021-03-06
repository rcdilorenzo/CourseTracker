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

    @NSManaged public var age: NSNumber?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var team: Team?
    @NSManaged var runs: NSSet
    
    public convenience init() {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
    }
    
    public convenience init(age: Int) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.age = age
    }
    
    public convenience init(firstName: String!, lastName: String!, age: Int, team: Team) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.team = team
    }
    
    public func fastestRun() -> Run? {
        let filteredRuns = Array(runs.filteredSetUsingPredicate(NSPredicate(format: "timeInterval > 0")))
        let sortDescriptor = NSSortDescriptor(key: "timeInterval", ascending: true)
        return (filteredRuns as NSArray).sortedArrayUsingDescriptors([sortDescriptor]).first as? Run
    }
    
    public func fastestRunTime() -> NSTimeInterval {
        if let run = fastestRun() {
            return run.timeInterval
        } else {
            return Double.infinity
        }
    }
    
    public func fastestRunDescription() -> String {
        if let run = fastestRun() {
            return "Best Time: \(formatTimeInSec(run.timeInterval))"
        } else {
            return "Best Time: none"
        }
    }
    
    public func addRun(run: Run) {
        let _runs = mutableSetValueForKey("runs")
        _runs.addObject(run)
    }
    
    public func nameAbbrev() -> String {
        return "\(firstName!) \((lastName! as NSString).substringToIndex(1))"
    }
    
    public func name() -> String {
        return "\(firstName!) \(lastName!)"
    }
    
    public func validate(completion: (Bool, String?) -> ()) {
        if firstName == nil || firstName!.isEmpty {
            completion(false, "First name is required.")
        } else if lastName == nil || lastName!.isEmpty {
            completion(false, "Last name is required.")
        } else if age == nil {
            completion(false, "Age is required.")
        } else if team == nil {
            completion(false, "Team is required.")
        } else {
            completion(true, nil)
        }
    }

}
