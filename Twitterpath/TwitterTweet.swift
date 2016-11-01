//
//  TwitterTweet.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import Foundation

class TwitterTweet {
    var text: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var timestamp: Date?
    var user: TwitterUser?
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = dictionary["retweet_count"] as? Int ?? 0
        favoritesCount = dictionary["favourites_count"] as? Int ?? 0
        
        if let timestampString = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }
        
        if let userDictionary = dictionary["user"] as? NSDictionary {
            user = TwitterUser(dictionary: userDictionary)
        }
    }

    init(text: String, retweetCount: Int = 0, favoritesCount: Int = 0, timestamp: Date, user: TwitterUser) {
        self.text = text
        self.retweetCount = retweetCount
        self.favoritesCount = favoritesCount
        self.timestamp = timestamp
        self.user = user
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [TwitterTweet] {
        var tweets: [TwitterTweet] = []
        
        for dictionary in dictionaries {
            tweets.append(TwitterTweet(dictionary: dictionary))
        }
        
        return tweets
    }
}

extension TwitterTweet: CustomStringConvertible {
    var description: String {
        return "text: \(text), retweets: \(retweetCount), favorites: \(favoritesCount), date: \(timestamp), user: \(user)"
    }
}
