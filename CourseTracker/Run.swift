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

    @NSManaged var end: NSDate?
    @NSManaged var start: NSDate?
    @NSManaged public var runners: NSSet
    @NSManaged public var timeInterval: Double
    @NSManaged public var running: Bool

    public convenience init(runners: [Runner]) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.runners = NSSet(array: runners)
    }
    
    public convenience init(timeInterval: NSTimeInterval, runner: Runner) {
        self.init(entity: self.dynamicType.entityDescription(), insertIntoManagedObjectContext: self.dynamicType.defaultContext())
        self.timeInterval = timeInterval
        runners = NSSet(object: runner)
    }
    
    lazy var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    // TODO: should be scoped to the course
    public class func fromRunners(runners: [Runner]) -> [Run] {
        let fetchRequest = self.fetchRequest()
        var predicates = [NSPredicate]()
        for runner in runners {
            predicates += [NSPredicate(format: "%@ IN runners", runner)]
        }
        predicates += [NSPredicate(format: "runners.@count == \(runners.count)")]
        fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicates)
        if let runs = defaultContext().executeFetchRequest(fetchRequest) as? [Run] {
            return runs
        } else {
            return []
        }
    }
    
    public class func deleteAllButFastestRun(runs: [Run]) {
        let fastestTime = (runs as NSArray).valueForKeyPath("@min.timeInterval") as! Double
        for run in runs {
            if run.timeInterval != fastestTime {
                defaultContext().deleteObject(run)
            }
        }
    }
    
    func timeDescription() -> String {
        return start == nil ? "" : timeFormatter.stringFromDate(start!)
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
        running = true
        end = nil
        timeInterval = 0
    }
    
    func stopRun() {
        end = NSDate()
        timeInterval = Double(end!.timeIntervalSinceDate(start!))
        running = false
    }
}
