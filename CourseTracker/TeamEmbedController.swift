//
//  TeamEmbedController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit

let cardInset = CGFloat(15)
let cardWidth = CGFloat(300)

class TeamEmbedController : UIViewController {
    
    @IBOutlet weak var teamActionsBackground: UIView!
    @IBOutlet var teamActions: [UIButton]!
    @IBOutlet weak var scrollView: UIScrollView!
    var teams = [Team]()
    var controllers = [TeamCardController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamActionsBackground.backgroundColor = secondaryColor()
        for button in teamActions {
            button.setTitleColor(primaryColor(), forState: .Normal)
        }
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        NSNotificationCenter.defaultCenter().addObserverForName("NewTeamAdded", object: nil, queue: nil) { (_) -> Void in
            self.refreshData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Determine why it doesn't layout properly if before appear
        self.refreshData()
    }
    
    func refreshData() {
        if Course.current() == nil {
            return
        }
        teams = Team.findAllByAttribute("course", value: Course.current()!) as! [Team]
        for controller in controllers {
            controller.removeFromParentViewController()
            controller.view.removeFromSuperview()
        }
        controllers = []
        var count = CGFloat(0)
        for team in teams {
            let teamCardController = storyboard?.instantiateViewControllerWithIdentifier("TeamCardController") as! TeamCardController
            teamCardController.team = team
            teamCardController.view.frame = CGRectMake(
                cardInset + count * cardInset * 2 + cardWidth * count,
                cardInset,
                cardWidth,
                view.frame.size.height - (cardInset * 2)
            )
            addChildViewController(teamCardController)
            scrollView.addSubview(teamCardController.view)
            controllers += [teamCardController]
            count++
        }
        scrollView.contentSize = CGSizeMake(count * cardInset * 2 + cardWidth * count, view.frame.size.height)
    }
    
    
}