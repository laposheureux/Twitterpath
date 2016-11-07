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
}

enum TweetListType: String {
    case home
    case mentions
}

class TweetListViewController: UIViewController {
    @IBOutlet var tweetsTableView: UITableView!
    
    var tweets: [TwitterTweet] = []
    var tweetListType: TweetListType = .home

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlChanged(refreshControl:)), for: .valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        if let navigationController = navigationController as? TweetsNavigationController {
            tweetListType = navigationController.timelineType
            switch tweetListType {
            case .home:
                navigationController.navigationBar.topItem?.title = "Home"
            case .mentions:
                navigationController.navigationBar.topItem?.title = "Mentions"
            }
            
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
        
        tweetsTableView.dataSource = self
        tweetsTableView.estimatedRowHeight = 90
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        refreshTimeline(showLoadingStatus: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let composeTweetVC = segue.destination as? ComposeTweetViewController {
            composeTweetVC.delegate = self
            if let replyButton = sender as? UIButton, let tweetCell = replyButton.superview?.superview as? TweetCell, let indexPath = tweetsTableView.indexPath(for: tweetCell), segue.identifier == "replyingSegue" {
                composeTweetVC.replyingToTweet = tweets[indexPath.row]
            }
        }

        if let singleTweetVC = segue.destination as? SingleTweetViewController, let tweetCell = sender as? TweetCell {
            singleTweetVC.delegate = self
            singleTweetVC.tweetViewDelegate = self
            if let indexPath = tweetsTableView.indexPath(for: tweetCell) {
                singleTweetVC.tweet = tweets[indexPath.row]
            }
        }
    }

    func refreshControlChanged(refreshControl: UIRefreshControl) {
        refreshTimeline(showLoadingStatus: false) {
            refreshControl.endRefreshing()
        }
    }

    func refreshTimeline(showLoadingStatus: Bool, completion: (() -> Void)?) {
        if showLoadingStatus { SVProgressHUD.show() }
        
        let successFunction = { [weak self] (tweets: [TwitterTweet]) in
            if showLoadingStatus { SVProgressHUD.dismiss() }
            self?.tweets = tweets
            self?.tweetsTableView.reloadData()
            completion?()
        }
        let failureFunction = { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            completion?()
        }
        
        switch tweetListType {
        case .home:
            TwitterAPI.sharedInstance.homeTimeline(success: successFunction, failure: failureFunction)
        case .mentions:
            TwitterAPI.sharedInstance.mentionsTimeline(success: successFunction, failure: failureFunction)
        }
        
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

        cell.selectionStyle = .none
        cell.twitterTweet = tweets[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension TweetListViewController: TweetUpdateable {
    func newTweet(tweet: TwitterTweet) {
        tweets.insert(tweet, at: 0)
        tweetsTableView.reloadData()
    }
}

extension TweetListViewController: TweetViewDelegate {
    func tweetView(tweetViewController: SingleTweetViewController, didSetLikeTo value: Bool, for tweet: TwitterTweet) {
        if value {
            TwitterAPI.sharedInstance.favorite(tweetID: tweet.idString, success: { [weak self] (newFavoriteCount: Int) in
                tweet.favoriteCount = newFavoriteCount
                tweet.favorited = true
                self?.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetViewController.retweetError()
            })
        } else {
            TwitterAPI.sharedInstance.unfavorite(tweetID: tweet.idString, success: { [weak self] (newFavoriteCount: Int) in
                tweet.favoriteCount = newFavoriteCount
                tweet.favorited = false
                self?.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetViewController.retweetError()
            })
        }
    }

    func tweetView(tweetViewController: SingleTweetViewController, didSetRetweetTo value: Bool, for tweet: TwitterTweet) {
        if value {
            TwitterAPI.sharedInstance.retweet(tweetID: tweet.idString, success: { [weak self] (newRetweetCount: Int) in
                tweet.retweetCount = newRetweetCount
                tweet.retweeted = true
                self?.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetViewController.retweetError()
            })
        } else {
            TwitterAPI.sharedInstance.unretweet(tweetID: tweet.idString, success: { [weak self] (newRetweetCount: Int) in
                tweet.retweetCount = newRetweetCount
                tweet.retweeted = false
                self?.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetViewController.retweetError()
            })
        }
    }
}

extension TweetListViewController: TweetCellDelegate {
    func tweetCell(tweetCell: TweetCell, didSetLikeTo value: Bool) {
        guard let indexPath = tweetsTableView.indexPath(for: tweetCell) else {
            tweetCell.likeError()
            return
        }

        if value {
            TwitterAPI.sharedInstance.favorite(tweetID: tweets[indexPath.row].idString, success: { [weak self] (newFavoriteCount: Int) in
                self?.tweets[indexPath.row].favoriteCount = newFavoriteCount
                self?.tweets[indexPath.row].favorited = true
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetCell.likeError()
            })
        } else {
            TwitterAPI.sharedInstance.unfavorite(tweetID: tweets[indexPath.row].idString, success: { [weak self] (newFavoriteCount: Int) in
                self?.tweets[indexPath.row].favoriteCount = newFavoriteCount
                self?.tweets[indexPath.row].favorited = false
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetCell.likeError()
            })
        }
    }

    func tweetCell(tweetCell: TweetCell, didSetRetweetTo value: Bool) {
        guard let indexPath = tweetsTableView.indexPath(for: tweetCell) else {
            tweetCell.retweetError()
            return
        }

        if value {
            TwitterAPI.sharedInstance.retweet(tweetID: tweets[indexPath.row].idString, success: { [weak self] (newRetweetCount: Int) in
                self?.tweets[indexPath.row].retweetCount = newRetweetCount
                self?.tweets[indexPath.row].retweeted = true
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetCell.retweetError()
            })
        } else {
            TwitterAPI.sharedInstance.unretweet(tweetID: tweets[indexPath.row].idString, success: { [weak self] (newRetweetCount: Int) in
                self?.tweets[indexPath.row].retweetCount = newRetweetCount
                self?.tweets[indexPath.row].retweeted = false
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                tweetCell.retweetError()
            })
        }
    }
}
