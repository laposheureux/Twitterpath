//
//  ProfileNavigationController.swift
//  Twitterpath
//
//  Created by Aaron on 11/7/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class ProfileNavigationController: UINavigationController {
    var screenname: String? {
        didSet {
            if let screenname = screenname {
                popToRootViewController(animated: false)
                let profileViewController = topViewController as! ProfileViewController
                profileViewController.screenname = screenname
            }
        }
    }
}
