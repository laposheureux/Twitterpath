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
        
        navigationController?.navigationBar.topItem?.title = "Home"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tweetsTableView.dataSource = self
        tweetsTableView.estimatedRowHeight = 90
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        SVProgressHUD.show()
        
        TwitterAPI.sharedInstance.homeTimeline(success: { [weak self] (tweets: [TwitterTweet]) in
            SVProgressHUD.dismiss()
            self?.tweets = tweets
            self?.tweetsTableView.reloadData()
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

extension TweetListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        
        cell.twitterTweet = tweets[indexPath.row]
        
        return cell
    }
}
