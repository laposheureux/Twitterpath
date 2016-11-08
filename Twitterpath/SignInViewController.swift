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
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        SVProgressHUD.show()
        TwitterAPI.sharedInstance.login(success: {
            SVProgressHUD.showSuccess(withStatus: "Logged in!")
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            if let appDelegate = appDelegate {
                appDelegate.showHamburger()
            } else {
                SVProgressHUD.showError(withStatus: "Application is in an unexpected state, please relaunch.")
            }
        }, failure: { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
}
