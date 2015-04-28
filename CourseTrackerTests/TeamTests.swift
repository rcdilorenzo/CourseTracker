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

class TeamTests: XCTestCase {
    let context: NSManagedObjectContext = inMemoryContext()
    
    func testGettingRuns() {
        let team = Team(name: "My Team", color: "#fff")
        
        let firstRunner = Runner(firstName: "John", lastName: "Doe", age: 13, team: team)
        let secondRunner = Runner(firstName: "Jane", lastName: "Doe", age: 11, team: team)
        
        let firstRun = Run(runners: NSSet(array: [firstRunner, secondRunner]))
        let secondRun = Run(runners: NSSet(array: [secondRunner, firstRunner]))
        let thirdRun = Run(runners: NSSet(array: [secondRunner]))
        
        XCTAssertEqual(team.runs().count, 3)
    }
    
}
