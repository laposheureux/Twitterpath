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
    case userData = "1.1/account/verify_credentials.json"
    case userTimeline = "1.1/statuses/home_timeline.json"
}

class TwitterAPI {
    static let twitterClient = BDBOAuth1SessionManager(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "xcsL1jwdu37vjIczwJlw1Ujho", consumerSecret: "x5TntrxGlLVggUuEcN14mTbLf7Cxqqsd01XM2rNDJWoycscRtm")!
    
    
    // MARK: - Authentication
    
    static var authorized: Bool {
        return twitterClient.isAuthorized
    }
    
    static func fetchRequestToken(success: @escaping ((BDBOAuth1Credential?) -> Void), failure: @escaping ((Error?) -> Void)) {
        twitterClient.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterpath://oauth"), scope: nil, success: success, failure: failure)
    }
    
    static func fetchAccessToken(forRequestToken requestToken: BDBOAuth1Credential, success: @escaping ((BDBOAuth1Credential?) -> Void), failure: @escaping ((Error?) -> Void)) {
        twitterClient.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: success, failure: failure)
    }
    
    // Helper function for accessing credentials semantically
    static func verifyCredentials(success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error) -> Void)) {
        fetch(twitterDataType: .userData, success: success, failure: failure)
    }

    
    // MARK: - User-contextual Information
    
    static func fetch(twitterDataType: TwitterDataType, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error) -> Void)) {
        twitterClient.get(twitterDataType.rawValue, parameters: nil, progress: nil, success: success, failure: failure)
    }
}
