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

class RunnerTests: XCTestCase {
    let context: NSManagedObjectContext = inMemoryContext()

    
    func testFindBestRun() {
        context.reset()
        let team = Team(name: "My Team", color: UIColor.blackColor())
        let runner = Runner(firstName: "Jacob", lastName: "Di Lorenzo", age: 9, team: team)
        let run1 = Run(timeInterval: 102.34, runner: runner)
        let run2 = Run(timeInterval: 98.21, runner: runner)
        let run3 = Run(timeInterval: 101.63, runner: runner)
        XCTAssertEqual(runner.fastestRun()!, run2)
        XCTAssertEqual(runner.fastestRunDescription(), "Best Time: 01:38.210")
    }
    
}
