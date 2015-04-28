//
//  Run.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

public class Run: NSManagedObject {

    @NSManaged var end: NSDate
    @NSManaged var start: NSDate
    @NSManaged var runners: NSSet

    public convenience init(runners: NSSet) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.runners = runners
    }
}
