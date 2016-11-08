//
//  TwitterAPI.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

enum TwitterFetchDataType: String {
    case anyUserData = "1.1/users/lookup.json"
    case homeTimeline = "1.1/statuses/home_timeline.json"
    case mentionsTimeline = "1.1/statuses/mentions_timeline.json"
    case userData = "1.1/account/verify_credentials.json"
    case userTimeline = "1.1/statuses/user_timeline.json"
}

enum TwitterPostDataType: String {
    case favorite = "1.1/favorites/create.json"
    case retweet = "1.1/statuses/retweet/:id:.json"
    case tweet = "1.1/statuses/update.json"
    case unFavorite = "1.1/favorites/destroy.json"
    case unRetweet = "1.1/statuses/unretweet/:id:.json"
}

enum TwitterAPIError: Error {
    case emptyTweet
    case unableToParseResponse
    case unknownError
    
    var localizedDescription: String {
        switch (self) {
        case .emptyTweet:
            return NSLocalizedString("Tweets must contain at least one character.", comment: "")
        case .unableToParseResponse:
            return NSLocalizedString("Unable to parse the JSON response from Twitter.", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error occurred, please try again.", comment: "")
        }
    }
}

class TwitterAPI {
    static let sharedInstance = TwitterAPI(twitterClient: BDBOAuth1SessionManager(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "xcsL1jwdu37vjIczwJlw1Ujho", consumerSecret: "x5TntrxGlLVggUuEcN14mTbLf7Cxqqsd01XM2rNDJWoycscRtm")!)
    static let logoutNotification = Notification.Name("userDidLogout")
    
    private let twitterClient: BDBOAuth1SessionManager
    
    private var twitterLoginSuccess: (() -> Void)?
    private var twitterLoginFailure: ((Error) -> Void)?
    
    private init(twitterClient: BDBOAuth1SessionManager) {
        self.twitterClient = twitterClient
    }
    
    
    // MARK: - Helper function wrapper around `get` and `post`
    
    private func fetch(twitterFetchDataPath: String, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error) -> Void)) {
        twitterClient.get(twitterFetchDataPath, parameters: nil, progress: nil, success: success, failure: failure)
    }

    private func post(twitterPostDataPath: String, parameters: Any?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error) -> Void)) {
        twitterClient.post(twitterPostDataPath, parameters: parameters, progress: nil, success: success, failure: failure)
    }
    
    
    // MARK: - Authentication
    
    private func fetchRequestToken(success: @escaping ((BDBOAuth1Credential?) -> Void), failure: @escaping ((Error?) -> Void)) {
        twitterClient.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterpath://oauth"), scope: nil, success: success, failure: failure)
    }
    
    private func fetchAccessToken(forRequestToken requestToken: BDBOAuth1Credential, success: @escaping ((BDBOAuth1Credential?) -> Void), failure: @escaping ((Error?) -> Void)) {
        twitterClient.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: success, failure: failure)
    }
    
    static var isAuthorized: Bool {
        return sharedInstance.twitterClient.isAuthorized
    }
    
    // Helper function for token retrieval
    func login(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        twitterLoginSuccess = success
        twitterLoginFailure = failure
        
        twitterClient.deauthorize()
        fetchRequestToken(success: { (requestToken: BDBOAuth1Credential?) in
            if let oauthToken = requestToken?.token {
                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(oauthToken)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.twitterLoginFailure?(TwitterAPIError.unknownError)
            }
        }, failure: { (error: Error?) in
            if let error = error {
                self.twitterLoginFailure?(error)
            } else {
                self.twitterLoginFailure?(TwitterAPIError.unknownError)
            }
        })
    }
    
    func logout() {
        twitterClient.deauthorize()
        TwitterUser.currentUser = nil
        
        NotificationCenter.default.post(name: TwitterAPI.logoutNotification, object: nil)
    }
    
    func continueLoginFromTwitter(with requestToken: BDBOAuth1Credential) {
        fetchAccessToken(forRequestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            if (accessToken?.token) != nil {
                self.currentAccount(success: { (user: TwitterUser) in
                    TwitterUser.currentUser = user
                    self.twitterLoginSuccess?()
                }, failure: { (error: Error) in
                    self.twitterLoginFailure?(error)
                })
            } else {
                self.twitterLoginFailure?(TwitterAPIError.unknownError)
            }
        }, failure: { (error: Error?) in
            if let error = error {
                self.twitterLoginFailure?(error)
            } else {
                self.twitterLoginFailure?(TwitterAPIError.unknownError)
            }
        })
    }
    
    // MARK: - User data
    
    func currentAccount(success: @escaping ((TwitterUser) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterFetchDataPath: TwitterFetchDataType.userData.rawValue, success: { (task: URLSessionDataTask, response: Any?) in
            if let userDictionary = response as? NSDictionary {
                success(TwitterUser(dictionary: userDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func profileData(withScreenname screenname: String, success: @escaping ((TwitterUser) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterFetchDataPath: "\(TwitterFetchDataType.anyUserData.rawValue)?screen_name=\(screenname)", success: { (task: URLSessionDataTask, response: Any?) in
            if let userDictionary = response as? [NSDictionary] {
                success(TwitterUser(dictionary: userDictionary.first!))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }

    
    // MARK: - Timelines
    
    func homeTimeline(success: @escaping (([TwitterTweet]) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterFetchDataPath: TwitterFetchDataType.homeTimeline.rawValue, success: { (task: URLSessionDataTask, response: Any?) in
            if let tweetsDictionary = response as? [NSDictionary] {
                success(TwitterTweet.tweetsWithArray(dictionaries: tweetsDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func mentionsTimeline(success: @escaping (([TwitterTweet]) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterFetchDataPath: TwitterFetchDataType.mentionsTimeline.rawValue, success: { (task: URLSessionDataTask, response: Any?) in
            if let tweetsDictionary = response as? [NSDictionary] {
                success(TwitterTweet.tweetsWithArray(dictionaries: tweetsDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func userTimeline(withScreenname screenname: String, success: @escaping (([TwitterTweet]) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterFetchDataPath: "\(TwitterFetchDataType.userTimeline.rawValue)?screen_name=\(screenname)", success: { (task: URLSessionDataTask, response: Any?) in
            if let tweetsDictionary = response as? [NSDictionary] {
                success(TwitterTweet.tweetsWithArray(dictionaries: tweetsDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }


    // MARK: - User actions

    func submitTweet(tweet: TwitterTweet, replyingToTweet: TwitterTweet?, success: (() -> Void)?, failure: ((Error) -> Void)?) {
        var parameters: [String: String] = [:]
        if let status = tweet.text {
            parameters["status"] = status
            if let replyingToTweet = replyingToTweet {
                parameters["in_reply_to_status_id"] = replyingToTweet.idString
            }
            post(twitterPostDataPath: TwitterPostDataType.tweet.rawValue, parameters: parameters, success: { (task: URLSessionDataTask, response: Any?) in
                success?()
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure?(error)
            })
        } else {
            failure?(TwitterAPIError.emptyTweet)
        }
    }

    func retweet(tweetID: String, success: ((Int) -> Void)?, failure: ((Error) -> Void)?) {
        let substitutedPath = TwitterPostDataType.retweet.rawValue.replacingOccurrences(of: ":id:", with: tweetID)

        post(twitterPostDataPath: substitutedPath, parameters: ["id": tweetID], success: { (task: URLSessionDataTask, response: Any?) in
            if let responseDictionary = response as? NSDictionary, let retweetCount = responseDictionary["retweet_count"] as? Int {
                success?(retweetCount)
            }
            success?(0)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }

    func unretweet(tweetID: String, success: ((Int) -> Void)?, failure: ((Error) -> Void)?) {
        let substitutedPath = TwitterPostDataType.unRetweet.rawValue.replacingOccurrences(of: ":id:", with: tweetID)

        post(twitterPostDataPath: substitutedPath, parameters: ["id": tweetID], success: { (task: URLSessionDataTask, response: Any?) in
            if let responseDictionary = response as? NSDictionary, let retweetCount = responseDictionary["retweet_count"] as? Int {
                success?(retweetCount)
            }
            success?(0)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }

    func favorite(tweetID: String, success: ((Int) -> Void)?, failure: ((Error) -> Void)?) {
        post(twitterPostDataPath: TwitterPostDataType.favorite.rawValue, parameters: ["id": tweetID], success: { (task: URLSessionDataTask, response: Any?) in
            if let responseDictionary = response as? NSDictionary, let retweetCount = responseDictionary["favorite_count"] as? Int {
                success?(retweetCount)
            }
            success?(0)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }

    func unfavorite(tweetID: String, success: ((Int) -> Void)?, failure: ((Error) -> Void)?) {
        post(twitterPostDataPath: TwitterPostDataType.unFavorite.rawValue, parameters: ["id": tweetID], success: { (task: URLSessionDataTask, response: Any?) in
            if let responseDictionary = response as? NSDictionary, let retweetCount = responseDictionary["favorite_count"] as? Int {
                success?(retweetCount)
            }
            success?(0)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }
}
