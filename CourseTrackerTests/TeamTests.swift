//
//  CourseTrackerTests.swift
//  CourseTrackerTests
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CourseTracker
import Dollar

class TeamTests: XCTestCase {
    let context: NSManagedObjectContext = inMemoryContext()
    
    override func setUp() {
        context.reset()
    }
    
    func testGettingRuns() {
        let team = Team(name: "My Team", color: UIColor.blackColor())
        
        let firstRunner = Runner(firstName: "John", lastName: "Doe", age: 13, team: team)
        let secondRunner = Runner(firstName: "Jane", lastName: "Doe", age: 11, team: team)
        
        let firstRun = Run(runners: [firstRunner, secondRunner])
        let secondRun = Run(runners: [secondRunner, firstRunner])
        let thirdRun = Run(runners: [secondRunner])
        
        XCTAssertEqual(team.runs().count, 3)
    }
    
    func testGettingByName() {
        let name = "One Team"
        let originalTeam = Team(name: name, color: UIColor.blackColor())
        let fetchedTeam = Team.byName(name)!
        
        XCTAssertEqual(originalTeam, fetchedTeam)
    }
    
    func testAverageTeamAge() {
        let team = Team(name: "My Team", color: UIColor.blackColor())
        let ages = [12, 14, 6, 7]
        for age in ages {
            runnerWithAge(age, team)
        }
        XCTAssertEqual(team.averageAge(), Double($.reduce(ages, initial: 0, combine: { $0 + $1 })) / Double(ages.count))
    }
    
    func testAutoAssignTeamRunnersCountIsFirstPriority() {
        let course = Course(name: "Course", details: nil)
        let team1 = teamWithAges([4, 8, 3, 6, 10], "1", course)
        let team2 = teamWithAges([12, 10, 46], "2", course)
        let team3 = teamWithAges([23, 11], "3", course)
        let team4 = teamWithAges([4, 8, 3, 6, 11], "4", course)
        let runner = Runner(age: 13)
        XCTAssertEqual(Team.forRunner(runner, inCourse: course), team3)
    }
    
    func testAutoAssignTeamRunnersAgeIsSecondPriority() {
        let course = Course(name: "Course", details: nil)
        let team1 = teamWithAges([10, 12], "1", course)
        let team2 = teamWithAges([4, 8], "2", course)
        let team3 = teamWithAges([23, 11], "3", course)
        let team4 = teamWithAges([4, 8, 3, 6, 11], "4", course)
        let runner = Runner(age: 13)
        XCTAssertEqual(Team.forRunner(runner, inCourse: course), team1)
    }

}
