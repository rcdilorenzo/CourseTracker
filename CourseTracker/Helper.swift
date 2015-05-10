//
//  Helper.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 5/7/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import Foundation
import Dollar

func formatTimeInSec(totalSeconds: NSTimeInterval) -> String {
    let milliseconds = NSNumber(double: round((totalSeconds - Double(trunc(totalSeconds))) * 1000))
    let seconds = NSNumber(double: totalSeconds % 60)
    let minutes = NSNumber(double: (totalSeconds / 60) % 60)
    let padding = 2
    
    return "\(padNumber(minutes.integerValue, 2)):\(padNumber(seconds.integerValue, 2)).\(padNumber(milliseconds.integerValue, 3))"
}

func padNumber(number: AnyObject, digits: Int) -> String {
    var string = "\(number)"
    while (string as NSString).length < digits {
        string = "0" + string
    }
    return string
}

func average(array: [Double]) -> Double {
    return $.reduce(array, initial: 0, combine: { $0 + $1 }) / Double(array.count)
}