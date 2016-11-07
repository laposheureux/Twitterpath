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
    var profileNavigationController: UIViewController!
    var tweetsNavigationController: UIViewController!
    var navControllers: [UIViewController] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.dataSource = self
        menuTableView.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "profileNavigationController")
        tweetsNavigationController = storyboard.instantiateViewController(withIdentifier: "tweetsNavigationController")
        
        navControllers.append(tweetsNavigationController)
        navControllers.append(profileNavigationController)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applicationSectionCell") as! ApplicationSectionCell
        
        if navControllers[indexPath.row] == tweetsNavigationController {
            cell.iconImage = #imageLiteral(resourceName: "Home")
            cell.label.text = NSLocalizedString("Home", comment: "")
        } else {
            cell.iconImage = #imageLiteral(resourceName: "Profile")
            cell.label.text = NSLocalizedString("Profile", comment: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navControllers.count
    }
}

extension MenuViewController: UITableViewDelegate {
    
}
