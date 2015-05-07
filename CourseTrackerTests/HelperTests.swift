//
//  HelperTests.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/7/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CourseTracker

class HelperTests: XCTestCase {
    
    func testPaddingNumber() {
        XCTAssertEqual(padNumber(3, 3), "003")
        XCTAssertEqual(padNumber(3, 1), "3")
    }

    func testConvertingSecondsToTimecode() {
        XCTAssertEqual(formatTimeInSec(62.5326), "01:02.533")
        XCTAssertEqual(formatTimeInSec(23.1), "00:23.100")
    }
}

