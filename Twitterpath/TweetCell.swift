//
//  TweetCell.swift
//  Twitterpath
//
//  Created by Aaron on 10/31/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

protocol TweetCellDelegate {
    func tweetCell(tweetCell: TweetCell, didSetRetweetTo value: Bool)
    func tweetCell(tweetCell: TweetCell, didSetLikeTo value: Bool)
}

class TweetCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var tweet: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    
    var twitterTweet: TwitterTweet? {
        didSet {
            if let twitterTweet = twitterTweet {
                tweet.text = twitterTweet.text
                name.text = twitterTweet.user?.name

                if let screenname = twitterTweet.user?.screenname {
                    username.text = "@\(screenname)"
                }

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
    
    @IBAction func replyPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func retweetPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func likePressed(_ sender: UIButton) {
        
    }
    
    func retweetError() {
        
    }
    
    func likeError() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 6
        profileImageView.clipsToBounds = true
    }
}
