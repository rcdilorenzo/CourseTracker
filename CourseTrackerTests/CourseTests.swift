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

class CourseTests: XCTestCase {
    let context: NSManagedObjectContext = inMemoryContext()
    
    override func setUp() {
        context.reset()
    }
    
    func testCurrentCourse() {
        let course = Course(name: "Obstacle Day 1", details: nil)
        course.setCurrent()
        let retrievedCourse = Course.current()!
        XCTAssertEqual(course, retrievedCourse)
    }
    
    func testAverageAgeCourse() {
        let course = Course(name: "Obstacle Day 1", details: nil)
        let teamsAges: [[Int]] = [[4, 7, 16, 9], [3, 4, 16, 32], [18, 13, 7, 12, 10]]
        var allAges = [Int]()
        var count = 1
        for ages in teamsAges {
            teamWithAges(ages, "Team \(count)", course)
            allAges += ages
            count++
        }
        XCTAssertEqual(course.averageAge(), Double($.reduce(allAges, initial: 0, combine: { $0 + $1 })) / Double(allAges.count))
    }
    
}
