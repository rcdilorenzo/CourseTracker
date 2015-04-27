//
//  Team.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

class Team: NSManagedObject {

    @NSManaged var color: AnyObject
    @NSManaged var name: String
    @NSManaged var course: NSManagedObject
    @NSManaged var runners: NSSet

}
