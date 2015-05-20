//
//  TeamEmbedController.swift
//  CourseTracker
//
//  Created by Christian Di Lorenzo on 4/27/15.
//  Copyright (c) 2015 Christian Di Lorenzo. All rights reserved.
//

import UIKit

let cardSpacer = CGFloat(15)
let cardWidth = CGFloat(250)

class TeamEmbedController : UIViewController {
    

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    var teams = [Team]()
    var controllers = [TeamCardController]()
    
    override func viewDidLoad() {
        toolbar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI/2))
        for view in toolbar.subviews as! [UIView] {
            if !view.isKindOfClass(UIImageView.classForCoder()) {
                view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(-M_PI/2))
            }
        }
        toolbar.transform = CGAffineTransformConcat(toolbar.transform, CGAffineTransformMakeTranslation(-toolbar.frame.origin.x, -toolbar.frame.origin.y))
        
        toolbar.barTintColor = secondaryColor()
        toolbar.tintColor = primaryColor()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        NSNotificationCenter.defaultCenter().addObserverForName("TeamsChanged", object: nil, queue: nil) { (_) -> Void in
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
        teams = (Team.findAllByAttribute("course", value: Course.current()!) as! [Team]).sorted({ $0.name < $1.name })
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
                (count + 1) * cardSpacer * 2 + cardWidth * count,
                cardSpacer,
                cardWidth,
                view.frame.size.height - (cardSpacer * 2)
            )
            addChildViewController(teamCardController)
            scrollView.addSubview(teamCardController.view)
            teamCardController.view.autoresizingMask = UIViewAutoresizing.None
            controllers += [teamCardController]
            count++
        }
        scrollView.contentSize = CGSizeMake((count + 1) * cardSpacer * 2 + cardWidth * count, view.frame.size.height)
    }
    
    
}