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
        
        if let profileImageURLString = dictionary["profile_image_url_https"] as? String {
            profileImageURL = URL(string: profileImageURLString)
        }
    }
    
    init(name: String?, screenname: String?, tagline: String?, profileImageURL: URL?) {
        self.name = name
        self.screenname = screenname
        self.tagline = tagline
        self.profileImageURL = profileImageURL
    }
    
    
    // MARK: - NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        let name = decoder.decodeObject(forKey: "name") as? String
        let screenname = decoder.decodeObject(forKey: "screenname") as? String
        let tagline = decoder.decodeObject(forKey: "tagline") as? String
        let profileImageURL = decoder.decodeObject(forKey: "profileImageURL") as? URL
        
        self.init(name: name, screenname: screenname, tagline: tagline, profileImageURL: profileImageURL)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(screenname, forKey: "screenname")
        aCoder.encode(tagline, forKey: "tagline")
        aCoder.encode(profileImageURL, forKey: "profileImageURL")
    }
}
