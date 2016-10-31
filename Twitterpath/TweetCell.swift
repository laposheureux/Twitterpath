//
//  TweetCell.swift
//  Twitterpath
//
//  Created by Aaron on 10/31/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func tweetCell(tweetCell: TweetCell, didSetRetreetTo value: Bool)
    @objc optional func tweetCell(tweetCell: TweetCell, didSetLikeTo value: Bool)
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
                username.text = twitterTweet.user?.screenname
                
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
