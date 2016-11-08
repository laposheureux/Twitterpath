//
//  MenuViewController.swift
//  Twitterpath
//
//  Created by Aaron on 11/6/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet var menuTableView: UITableView!
    var profileNavigationController: ProfileNavigationController!
    var tweetsNavigationController: TweetsNavigationController!
    var mentionsNavigationController: TweetsNavigationController!
    var hamburgerViewController: HamburgerViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.dataSource = self
        menuTableView.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "profileNavigationController") as! ProfileNavigationController
        tweetsNavigationController = storyboard.instantiateViewController(withIdentifier: "tweetsNavigationController") as! TweetsNavigationController
        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "tweetsNavigationController") as! TweetsNavigationController
        
        tweetsNavigationController.timelineType = .home
        mentionsNavigationController.timelineType = .mentions
        
        hamburgerViewController.contentViewController = tweetsNavigationController
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToProfile(notification:)), name: NSNotification.Name("switchToProfile"), object: nil)
    }
    
    func switchToProfile(notification: Notification) {
        if let screenname = notification.userInfo?["screenname"] as? String {
            profileNavigationController.screenname = screenname
            hamburgerViewController.contentViewController = profileNavigationController
        }
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applicationSectionCell") as! ApplicationSectionCell
        
        if indexPath.row == 0 {
            cell.iconImage = #imageLiteral(resourceName: "Home")
            cell.label.text = NSLocalizedString("Home", comment: "")
        } else if indexPath.row == 1 {
            cell.iconImage = #imageLiteral(resourceName: "Mention")
            cell.label.text = NSLocalizedString("Mentions", comment: "")
        } else {
            cell.iconImage = #imageLiteral(resourceName: "Profile")
            cell.label.text = NSLocalizedString("Profile", comment: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            hamburgerViewController.contentViewController = tweetsNavigationController
        } else if  indexPath.row == 1 {
            hamburgerViewController.contentViewController = mentionsNavigationController
        } else {
            profileNavigationController.screenname = TwitterUser.currentUser?.screenname
            hamburgerViewController.contentViewController = profileNavigationController
        }
    }
}
