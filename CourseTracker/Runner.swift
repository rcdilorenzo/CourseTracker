//
//  Runner.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

class Runner: NSManagedObject {

    @NSManaged var age: NSNumber
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var team: NSManagedObject
    @NSManaged var runs: NSSet

}
