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

    lazy var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()

    func timeDescription() -> String {
        return timeFormatter.stringFromDate(start!)
    }

    public func runnerNames() -> String {
        let sortedRunners = runners.sortedArrayUsingDescriptors([NSSortDescriptor(key: "firstName", ascending: true)]) as! [Runner]
        switch runners.count {
        case 0:
            return ""
        case 1:
            return sortedRunners.first!.name()
        case 2:
            return "\(sortedRunners[0].nameAbbrev()). and \(sortedRunners[1].nameAbbrev())."
        default:
            let namesMinusLast = (sortedRunners as NSArray).subarrayWithRange(NSMakeRange(0, sortedRunners.count-1)).map({ $0.nameAbbrev() })
            return join(", ", namesMinusLast) + ", and \(sortedRunners.last!.nameAbbrev())"
        }
    }

    func startRun() {
        start = NSDate()
        end = nil
        timeInterval = 0
    }

    func stopRun() {
        end = NSDate()
        timeInterval = Double(end!.timeIntervalSinceDate(start!))
    }
}
