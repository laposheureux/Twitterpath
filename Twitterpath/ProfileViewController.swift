//
//  ProfileViewController.swift
//  Twitterpath
//
//  Created by Aaron on 11/6/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileViewController: UIViewController {
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var numberOfTweetsLabel: UILabel!
    @IBOutlet var numberFollowingLabel: UILabel!
    @IBOutlet var numberFollowersLabel: UILabel!
    
    var screenname: String? {
        didSet {
            if let screenname = screenname {
                loadProfile(with: screenname)
            }
        }
    }
    
    var twitterUser: TwitterUser? {
        didSet {
            if let twitterUser = twitterUser {
                if let profileCoverImageURL = twitterUser.profileCoverImageURL {
                    coverImageView.setImageWith(profileCoverImageURL)
                }
                
                if let profileImageURL = twitterUser.profileImageURL {
                    profileImageView.setImageWith(profileImageURL, placeholderImage: #imageLiteral(resourceName: "ProfilePlaceholder"))
                } else {
                    profileImageView.image = #imageLiteral(resourceName: "ProfilePlaceholder")
                }
                
                displayNameLabel.text = twitterUser.name
                usernameLabel.text = twitterUser.screenname
                
                if let numTweets = twitterUser.numberTweets {
                    numberOfTweetsLabel.text = String(numTweets)
                } else {
                    numberOfTweetsLabel.text = "0"
                }
                if let numFollowing = twitterUser.numberFollowing {
                    numberFollowingLabel.text = String(numFollowing)
                } else {
                    numberFollowingLabel.text = "0"
                }
                if let numFollowers = twitterUser.numberFollowers {
                    numberFollowersLabel.text = String(numFollowers)
                } else {
                    numberFollowersLabel.text = "0"
                }
            }
        }
    }
    
    func loadProfile(with screenname: String) {
        TwitterAPI.sharedInstance.profileData(withScreenname: screenname, success: { [weak self] (user: TwitterUser) in
            self?.twitterUser = user
        }, failure: { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = navigationController {
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
        
        twitterUser = TwitterUser.currentUser
    }
}
