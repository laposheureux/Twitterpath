//
//  TweetListViewController.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol TweetUpdateable: class {
    func newTweet(tweet: TwitterTweet)
    func updateTweet(newTweet: TwitterTweet, oldTweet: TwitterTweet)
}

class TweetListViewController: UIViewController {
    @IBOutlet var tweetsTableView: UITableView!
    
    var tweets: [TwitterTweet] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlChanged(refreshControl:)), for: .valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        navigationController?.navigationBar.topItem?.title = "Home"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tweetsTableView.dataSource = self
        tweetsTableView.estimatedRowHeight = 90
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        refreshTimeline(completion: nil)

//        TwitterAPI.verifyCredentials(success: { (user: TwitterUser) in
//            TwitterUser.currentUser = user
//        }, failure: { (error: Error) in
//            SVProgressHUD.showError(withStatus: error.localizedDescription)
//        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let composeTweetVC = segue.destination as? ComposeTweetViewController {
            composeTweetVC.delegate = self
        }
    }

    func refreshControlChanged(refreshControl: UIRefreshControl) {
        refreshTimeline { 
            refreshControl.endRefreshing()
        }
    }

    func refreshTimeline(completion: (() -> Void)?) {
        SVProgressHUD.show()
        TwitterAPI.sharedInstance.homeTimeline(success: { [weak self] (tweets: [TwitterTweet]) in
            SVProgressHUD.dismiss()
            self?.tweets = tweets
            self?.tweetsTableView.reloadData()
            completion?()
        }, failure: { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            completion?()
        })
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

extension TweetListViewController: TweetUpdateable {
    func newTweet(tweet: TwitterTweet) {
        tweets.insert(tweet, at: 0)
        tweetsTableView.reloadData()
    }
}
