//
//  TweetListViewController.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD

class TweetListViewController: UIViewController {
    @IBOutlet var tweetsTableView: UITableView!
    
    var tweets: [TwitterTweet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TwitterAPI.sharedInstance.homeTimeline(success: { (tweets: [TwitterTweet]) in
            self.tweets = tweets
        }, failure: { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
        
//        TwitterAPI.verifyCredentials(success: { (user: TwitterUser) in
//            TwitterUser.currentUser = user
//        }, failure: { (error: Error) in
//            SVProgressHUD.showError(withStatus: error.localizedDescription)
//        })
    }
    
    @IBAction func composeTweet(_ sender: UIBarButtonItem) {
    
    }

    @IBAction func signOut(_ sender: UIBarButtonItem) {
        TwitterAPI.sharedInstance.logout()
    }
}

