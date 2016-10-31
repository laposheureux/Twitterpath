//
//  TwitterAPI.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

enum TwitterDataType: String {
    case homeTimeline = "1.1/statuses/home_timeline.json"
    case userData = "1.1/account/verify_credentials.json"
}

enum TwitterAPIError: Error {
    case unableToParseResponse
    case unknownError
    
    var localizedDescription: String {
        switch (self) {
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
    
    
    // MARK: - Helper function wrapper around `get`
    
    private func fetch(twitterDataType: TwitterDataType, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error) -> Void)) {
        twitterClient.get(twitterDataType.rawValue, parameters: nil, progress: nil, success: success, failure: failure)
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
    
    // Helper function for accessing credentials semantically
    func currentAccount(success: @escaping ((TwitterUser) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterDataType: .userData, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            if let userDictionary = response as? NSDictionary {
                success(TwitterUser(dictionary: userDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }

    
    // MARK: - User-contextual Information
    
    func homeTimeline(success: @escaping (([TwitterTweet]) -> Void), failure: @escaping ((Error) -> Void)) {
        fetch(twitterDataType: .homeTimeline, success: { (task: URLSessionDataTask, response: Any?) in
            if let tweetsDictionary = response as? [NSDictionary] {
                success(TwitterTweet.tweetsWithArray(dictionaries: tweetsDictionary))
            } else {
                failure(TwitterAPIError.unableToParseResponse)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
}
