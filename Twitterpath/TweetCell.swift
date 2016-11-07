//
//  TweetCell.swift
//  Twitterpath
//
//  Created by Aaron on 10/31/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

protocol TweetCellDelegate: class {
    func tweetCell(tweetCell: TweetCell, didSetRetweetTo value: Bool)
    func tweetCell(tweetCell: TweetCell, didSetLikeTo value: Bool)
}

class TweetCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var tweet: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var retweetButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    
    var twitterTweet: TwitterTweet? {
        didSet {
            if let twitterTweet = twitterTweet {
                tweet.text = twitterTweet.text
                name.text = twitterTweet.user?.name

                if let screenname = twitterTweet.user?.screenname {
                    username.text = "@\(screenname)"
                }

                retweetButton.tintColor = twitterTweet.retweeted ? TwitterColors.retweetedColor : TwitterColors.twitterDarkGrey
                likeButton.tintColor = twitterTweet.favorited ? TwitterColors.likedColor : TwitterColors.twitterDarkGrey

                if let date = twitterTweet.timestamp {
                    let timeSinceFormatter = DateComponentsFormatter()
                    let calendar = Calendar.current
                    let timeSinceComponents = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: date, to: Date())
                    var suffix: String

                    if let year = timeSinceComponents.year, year > 0 {
                        timeSinceFormatter.allowedUnits = .year
                        suffix = NSLocalizedString("y", comment: "Shorthand for 'year'")
                    } else if let month = timeSinceComponents.month, month > 0 {
                        timeSinceFormatter.allowedUnits = .month
                        suffix = NSLocalizedString("M", comment: "Shorthand for 'month'")
                    } else if let week = timeSinceComponents.weekOfMonth, week > 0 {
                        timeSinceFormatter.allowedUnits = .weekOfMonth
                        suffix = NSLocalizedString("w", comment: "Shorthand for 'week'")
                    } else if let day = timeSinceComponents.day, day > 0 {
                        timeSinceFormatter.allowedUnits = .day
                        suffix = NSLocalizedString("d", comment: "Shorthand for 'day'")
                    } else if let hour = timeSinceComponents.hour, hour > 0 {
                        timeSinceFormatter.allowedUnits = .hour
                        suffix = NSLocalizedString("h", comment: "Shorthand for 'hour'")
                    } else if let minute = timeSinceComponents.minute, minute > 0 {
                        timeSinceFormatter.allowedUnits = .minute
                        suffix = NSLocalizedString("m", comment: "Shorthand for 'minute'")
                    } else {
                        timeSinceFormatter.allowedUnits = .second
                        suffix = NSLocalizedString("s", comment: "Shorthand for 'second'")
                    }

                    if let conciseTimeSinceString = timeSinceFormatter.string(from: timeSinceComponents) {
                        timestamp.text = "\(conciseTimeSinceString)\(suffix)"
                    }
                }
                
                if let imageURL = twitterTweet.user?.profileImageURL {
                    profileImageView.setImageWith(imageURL)
                } else {
                    profileImageView.image = #imageLiteral(resourceName: "ProfilePlaceholder")
                }
            }
        }
    }

    weak var delegate: TweetCellDelegate?
    
    @IBAction func retweetPressed(_ sender: UIButton) {
        if let retweeted = twitterTweet?.retweeted {
            delegate?.tweetCell(tweetCell: self, didSetRetweetTo: !retweeted)
        }
        flipRetweet()
    }
    
    @IBAction func likePressed(_ sender: UIButton) {
        if let favorited = twitterTweet?.favorited {
            delegate?.tweetCell(tweetCell: self, didSetLikeTo: !favorited)
        }
        flipFavorite()
    }

    private func flipRetweet() {
        if let retweeted = twitterTweet?.retweeted {
            twitterTweet?.retweeted = !retweeted
            retweetButton.tintColor = !retweeted ? TwitterColors.retweetedColor : TwitterColors.twitterDarkGrey
        }
    }

    private func flipFavorite() {
        if let favorited = twitterTweet?.favorited {
            twitterTweet?.favorited = !favorited
            likeButton.tintColor = !favorited ? TwitterColors.likedColor : TwitterColors.twitterDarkGrey
        }
    }
    
    func retweetError() {
        flipRetweet()
    }
    
    func likeError() {
        flipFavorite()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 6
        profileImageView.clipsToBounds = true
    }
}
