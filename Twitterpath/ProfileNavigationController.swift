//
//  ProfileNavigationController.swift
//  Twitterpath
//
//  Created by Aaron on 11/7/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class ProfileNavigationController: UINavigationController {
    var profileID: String? {
        didSet {
            if let profileID = profileID {
                popToRootViewController(animated: false)
                let profileViewController = topViewController as! ProfileViewController
                profileViewController.profileID = profileID
            }
        }
    }
}
