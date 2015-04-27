//
//  Run.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var end: NSDate
    @NSManaged var start: NSDate
    @NSManaged var runners: NSSet

}
