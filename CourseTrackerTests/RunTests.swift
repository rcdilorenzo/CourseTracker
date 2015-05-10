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


class RunTests: XCTestCase {
    let context: NSManagedObjectContext = inMemoryContext()
    var team: Team?
    var runner1: Runner?
    var runner2: Runner?
    var runner3: Runner?
    
    override func setUp() {
        context.reset()
        team = Team(name: "My Team", color: UIColor.whiteColor())
        runner1 = Runner(firstName: "John", lastName: "Doe", age: 9, team: team!)
        runner2 = Runner(firstName: "Rick", lastName: "Johnson", age: 11, team: team!)
        runner3 = Runner(firstName: "Amy", lastName: "Silverstein", age: 13, team: team!)
    }
    
    func testGettingSingleRunnerName() {
        let run = Run(runners: NSSet(object: runner1!))
        XCTAssertEqual(run.runnerNames(), "John Doe")
    }
    
    func testGettingTwoRunnerNames() {
        let run = Run(runners: NSSet(objects: runner2!, runner1!))
        XCTAssertEqual(run.runnerNames(), "John D. and Rick J.")
    }
    
    func testGettingManyRunnerNames() {
        let run = Run(runners: NSSet(objects: runner1!, runner2!, runner3!))
        XCTAssertEqual(run.runnerNames(), "Amy S, John D, and Rick J")
    }
    
}
