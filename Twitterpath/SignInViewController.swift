//
//  SignInViewController.swift
//  Twitterpath
//
//  Created by Aaron on 10/30/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SVProgressHUD

class SignInViewController: UIViewController {
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let isStoredAuthValid = false
        loginButton.isEnabled = !isStoredAuthValid
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        TwitterAPI.twitterClient.deauthorize()
        
        SVProgressHUD.show()
        TwitterAPI.fetchRequestToken(success: { (requestToken: BDBOAuth1Credential?) in
            if let oauthToken = requestToken?.token {
                SVProgressHUD.dismiss()
                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(oauthToken)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    }
}
