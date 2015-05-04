//
//  TeamCardController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit

let cellID = "teamRunsCellID"

class TeamCardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var titleBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var runs: [Run] = []
    var team: Team? {
        didSet {
            self.runs = team!.runs()
        }
    }
    
    override func viewDidLoad() {
        titleLabel.text = team?.name
        titleLabel.textColor = UIColor.whiteColor()
        titleBackground.backgroundColor = team?.color
        tableView.scrollEnabled = !runs.isEmpty
        noDataLabel.hidden = !runs.isEmpty
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TeamRankCell
        let run = runs[indexPath.row]
        return cell
    }
}