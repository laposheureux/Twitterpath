//
//  SingleTweetViewController.swift
//  Twitterpath
//
//  Created by Aaron L'Heureux on 10/31/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol TweetViewDelegate: class {
    func tweetView(tweetViewController: SingleTweetViewController, didSetRetweetTo value: Bool, for tweetID: TwitterTweet)
    func tweetView(tweetViewController: SingleTweetViewController, didSetLikeTo value: Bool, for tweetID: TwitterTweet)
}

class SingleTweetViewController: UIViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var screenname: UILabel!
    @IBOutlet var tweetText: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var retweetCount: UILabel!
    @IBOutlet var favoriteCount: UILabel!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var retweetButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    weak var delegate: TweetUpdateable?
    weak var tweetViewDelegate: TweetViewDelegate?

    var tweet: TwitterTweet!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tweet = tweet else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Tweet data not found, please try again.", comment: ""))
            navigationController?.popViewController(animated: false)
            return
        }

        if let imageURL = tweet.user?.profileImageURL {
            profileImageView.setImageWith(imageURL)
        } else {
            profileImageView.image = #imageLiteral(resourceName: "ProfilePlaceholder")
        }

        name.text = tweet.user?.name

        if let sn = tweet.user?.screenname {
            screenname.text = "@\(sn)"
        }

        tweetText.text = tweet.text

        if let date = tweet.timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            timestamp.text = dateFormatter.string(from: date)
        }

        retweetCount.text = String(tweet.retweetCount)
        favoriteCount.text = String(tweet.favoriteCount)

        retweetButton.tintColor = tweet.retweeted ? TwitterColors.retweetedColor : TwitterColors.twitterDarkGrey
        likeButton.tintColor = tweet.favorited ? TwitterColors.likedColor : TwitterColors.twitterDarkGrey
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let composeTweetVC = segue.destination as? ComposeTweetViewController, let delegate = delegate {
            // Pass delegate through for the purposes of updating the home timeline.
            composeTweetVC.delegate = delegate
            if sender as? UIButton == replyButton {
                composeTweetVC.replyingToTweet = tweet
            }
        }
    }

    private func flipRetweet() {
        retweetButton.tintColor = !tweet.retweeted ? TwitterColors.retweetedColor : TwitterColors.twitterDarkGrey
        retweetCount.text = tweet.retweeted ? String(tweet.retweetCount) : String(tweet.retweetCount + 1)
        tweet.retweeted = !tweet.retweeted
    }

    private func flipFavorite() {
        likeButton.tintColor = !tweet.favorited ? TwitterColors.likedColor : TwitterColors.twitterDarkGrey
        favoriteCount.text = tweet.favorited ? String(tweet.favoriteCount) : String(tweet.favoriteCount + 1)
        tweet.favorited = !tweet.favorited
    }

    func retweetError() {
        flipRetweet()
    }

    func likeError() {
        flipFavorite()
    }

    @IBAction func retweetPressed(_ sender: UIButton) {
        tweetViewDelegate?.tweetView(tweetViewController: self, didSetRetweetTo: !tweet.retweeted, for: tweet)
        flipRetweet()
    }

    @IBAction func likePressed(_ sender: UIButton) {
        tweetViewDelegate?.tweetView(tweetViewController: self, didSetLikeTo: !tweet.favorited, for: tweet)
        flipFavorite()
    }
}
