//
//  TestHelper.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit
import CourseTracker
import CoreData
import MBFaker

func appDelegate() -> CourseTracker.AppDelegate {
    return UIApplication.sharedApplication().delegate as! CourseTracker.AppDelegate
}

func setInMemoryStore() {
    appDelegate().inMemory = true;
}

func inMemoryContext() -> NSManagedObjectContext {
    setInMemoryStore()
    return appDelegate().managedObjectContext!
}

func runnerWithAge(age: Int, team: Team) -> Runner {
    return Runner(firstName: MBFakerName.firstName(), lastName: MBFakerName.firstName(), age: age, team: team)
}

func teamWithAges(ages: [Int], name: String, course: Course) -> Team {
    let team = Team(name: name, color: UIColor.blackColor())
    for age in ages {
        runnerWithAge(age, team)
    }
    team.course = course
    return team
}