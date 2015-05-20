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
    @NSManaged public var course: Course
    @NSManaged public var score: Double
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
    
    public class func forRunner(runner: Runner, inCourse course: Course) -> Team {
        let teams = course.teams.allObjects as! [Team]
        var sortedTeams = teams.sorted { (team1, team2) -> Bool in
            return team1.runners.count < team2.runners.count
        }
        let lowestRunnerCount = sortedTeams.first!.runners.count
        sortedTeams = sortedTeams.filter { (team) -> Bool in
            return team.runners.count == lowestRunnerCount
        }
        sortedTeams.sort { (team1, team2) -> Bool in
            return team1.averageAge() < team2.averageAge()
        }
        if let age = runner.age {
            return age.doubleValue > course.averageAge() ? sortedTeams.first! : sortedTeams.last!
        }
        return sortedTeams.first!
    }
    
    public func updateScore() {
        let allRuns = runs()
        if allRuns.count < 3 {
            score = Double.infinity
            return
        }
        let sortedRuns = Array(allRuns.sorted({ $0.timeInterval < $1.timeInterval })[0..<3])
        score =  $.reduce(sortedRuns, initial: 0, combine: { $0 + $1.timeInterval })
    }
    
    public func averageAge() -> Double {
        let ages = (runners.allObjects as! [Runner]).map({ $0.age!.doubleValue })
        return average(ages)
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
