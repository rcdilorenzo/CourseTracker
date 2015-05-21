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
        let run = Run(runners: [runner1!])
        XCTAssertEqual(run.runnerNames(), "John Doe")
    }
    
    func testGettingTwoRunnerNames() {
        let run = Run(runners: [runner2!, runner1!])
        XCTAssertEqual(run.runnerNames(), "John D. and Rick J.")
    }
    
    func testGettingManyRunnerNames() {
        let run = Run(runners: [runner1!, runner2!, runner3!])
        XCTAssertEqual(run.runnerNames(), "Amy S, John D, and Rick J")
    }
    
    func testGettingRunFromRunners() {
        let run1 = Run(runners: [runner1!, runner3!])
        run1.timeInterval = 23.4
        let run2 = Run(runners: [runner1!, runner3!])
        run2.timeInterval = 21.6
        let run3 = Run(runners: [runner2!, runner3!])
        run3.timeInterval = 11.2
        XCTAssert($.contains(Run.fromRunners([runner1!, runner3!]), value: run2))
        XCTAssertFalse($.contains(Run.fromRunners([runner1!, runner3!]), value: run3))
        
        XCTAssertEqual(([run1, run2] as NSArray).valueForKeyPath("@min.timeInterval") as! Double, 21.6)
    }
    
    func testDeletingAllButFastestRun() {
        let run1 = Run(runners: [runner1!])
        run1.timeInterval = 23.4
        let run2 = Run(runners: [runner1!])
        run2.timeInterval = 21.6
        let run3 = Run(runners: [runner1!])
        run3.timeInterval = 11.2
        
        Run.deleteAllButFastestRun([run1, run3, run2])
        XCTAssert(run1.deleted)
        XCTAssert(run2.deleted)
        XCTAssertFalse(run3.deleted)
    }
    
}
