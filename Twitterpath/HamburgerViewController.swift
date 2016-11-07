//
//  HamburgerViewController.swift
//  Twitterpath
//
//  Created by Aaron on 11/7/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet var menuView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var leftMarginConstraint: NSLayoutConstraint!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(prevContentViewController) {
            view.layoutIfNeeded()
            
            if prevContentViewController != nil {
                prevContentViewController.willMove(toParentViewController: nil)
                prevContentViewController.view.removeFromSuperview()
                prevContentViewController.didMove(toParentViewController: nil)
            }
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3) { 
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private var originalLeftMargin: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
        case .began:
            originalLeftMargin = leftMarginConstraint.constant
        case .changed:
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        case .ended:
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 100
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        default:
            break
        }
    }
}
