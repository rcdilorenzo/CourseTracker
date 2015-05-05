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
    
}
