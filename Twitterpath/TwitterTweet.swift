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
    var retweetCount: Int
    var retweeted: Bool
    var favoriteCount: Int
    var favorited: Bool
    var timestamp: Date?
    var idString: String
    var user: TwitterUser?
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = dictionary["retweet_count"] as? Int ?? 0
        favoriteCount = dictionary["favorite_count"] as? Int ?? 0
        idString = dictionary["id_str"] as? String ?? "0"

        retweeted = dictionary["retweeted"] as? Bool ?? false
        favorited = dictionary["favorited"] as? Bool ?? false
        
        if let timestampString = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }
        
        if let userDictionary = dictionary["user"] as? NSDictionary {
            user = TwitterUser(dictionary: userDictionary)
        }
    }

    init(text: String, retweetCount: Int = 0, retweeted: Bool = false, favoriteCount: Int = 0, favorited: Bool = false, timestamp: Date, user: TwitterUser) {
        self.text = text
        self.retweetCount = retweetCount
        self.retweeted = retweeted
        self.favoriteCount = favoriteCount
        self.favorited = favorited
        self.timestamp = timestamp
        self.idString = "0" // If we're manually creating a tweet like this, we don't have the actual ID from Twitter. This will cause a problem with replies that is so far not solved...
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
        return "text: \(text), retweets: \(retweetCount), favorites: \(favoriteCount), date: \(timestamp), user: \(user)"
    }
}
