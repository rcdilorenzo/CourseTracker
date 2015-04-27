//
//  Course.swift
//  
//
//  Created by Christian Di Lorenzo on 4/27/15.
//
//

import Foundation
import CoreData

class Course: NSManagedObject {

    @NSManaged var details: String
    @NSManaged var name: String
    @NSManaged var teams: NSSet

}
