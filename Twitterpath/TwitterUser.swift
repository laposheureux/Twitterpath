//
//  TwitterUser.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import Foundation

class TwitterUser: NSObject, NSCoding {
    var name: String?
    var screenname: String?
    var tagline: String?
    var profileImageURL: URL?
    var profileCoverImageURL: URL?
    var numberTweets: Int?
    var numberFollowing: Int?
    var numberFollowers: Int?
    
    static var _currentUser: TwitterUser?
    class var currentUser: TwitterUser? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                if let existingUserData = defaults.object(forKey: "currentUser") as? Data {
                    let existingUser = NSKeyedUnarchiver.unarchiveObject(with: existingUserData) as? TwitterUser
                    self._currentUser = existingUser
                    return existingUser
                }
            }
            
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                defaults.set(userData, forKey: "currentUser")
            } else {
                defaults.removeObject(forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        numberTweets = dictionary["statuses_count"] as? Int
        numberFollowing = dictionary["friends_count"] as? Int
        numberFollowers = dictionary["followers_count"] as? Int
        
        if let profileImageURLString = dictionary["profile_image_url_https"] as? String {
            profileImageURL = URL(string: profileImageURLString)
        }
        
        if let profileCoverImageURLString = dictionary["profile_background_image_url_https"] as? String {
            profileCoverImageURL = URL(string: profileCoverImageURLString)
        }
    }
    
    init(name: String?, screenname: String?, tagline: String?, numberTweets: Int?, numberFollowing: Int?, numberFollowers: Int?, profileImageURL: URL?, profileCoverImageURL: URL?) {
        self.name = name
        self.screenname = screenname
        self.tagline = tagline
        self.numberTweets = numberTweets
        self.numberFollowing = numberFollowing
        self.numberFollowers = numberFollowers
        self.profileImageURL = profileImageURL
        self.profileCoverImageURL = profileCoverImageURL
    }
    
    
    // MARK: - NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        let name = decoder.decodeObject(forKey: "name") as? String
        let screenname = decoder.decodeObject(forKey: "screenname") as? String
        let tagline = decoder.decodeObject(forKey: "tagline") as? String
        let numberTweets = decoder.decodeObject(forKey: "numberTweets") as? Int
        let numberFollowing = decoder.decodeObject(forKey: "numberFollowing") as? Int
        let numberFollowers = decoder.decodeObject(forKey: "numberFollowers") as? Int
        let profileImageURL = decoder.decodeObject(forKey: "profileImageURL") as? URL
        let profileCoverImageURL = decoder.decodeObject(forKey: "profileCoverImageURL") as? URL
        
        self.init(name: name, screenname: screenname, tagline: tagline, numberTweets: numberTweets, numberFollowing: numberFollowing, numberFollowers: numberFollowers, profileImageURL: profileImageURL, profileCoverImageURL: profileCoverImageURL)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(screenname, forKey: "screenname")
        aCoder.encode(tagline, forKey: "tagline")
        aCoder.encode(numberTweets, forKey: "numberTweets")
        aCoder.encode(numberFollowing, forKey: "numberFollowing")
        aCoder.encode(numberFollowers, forKey: "numberFollowers")
        aCoder.encode(profileImageURL, forKey: "profileImageURL")
        aCoder.encode(profileCoverImageURL, forKey: "profileCoverImageURL")
    }
}
