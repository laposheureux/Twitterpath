//
//  AppDelegate.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme, let query = url.query, scheme.hasPrefix("twitterpath") {
            let requestToken = BDBOAuth1Credential(queryString: query)!
            
            SVProgressHUD.show()
            TwitterAPI.fetchAccessToken(forRequestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
                if let token = accessToken?.token {
                    SVProgressHUD.dismiss()
                    TwitterAPI.verifyCredentials(success: { (task: URLSessionDataTask, response: Any?) in
                        // wat
                        TwitterAPI.fetch(twitterDataType: .userTimeline, success: { (task: URLSessionDataTask, response: Any?) in
                            let tweets = response as! [NSDictionary]
                            for tweet in tweets {
                                print("\(tweet["text"]!)")
                            }
                        }, failure: { (task: URLSessionDataTask?, error: Error) in
                            print("error fetching timeline")
                        })
                    }, failure: { (task: URLSessionDataTask?, error: Error) in
                        print("error verifying credentials")
                    })
                } else {
                    SVProgressHUD.showError(withStatus: NSLocalizedString("Did not receive a token from Twitter, please try again", comment: ""))
                }
            }, failure: { (error: Error?) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                } else {
                    SVProgressHUD.showError(withStatus: NSLocalizedString("Unknown error occurred, please try again.", comment: ""))
                }
            })
            
            return true
        }
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

