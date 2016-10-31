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
        TwitterAPI.sharedInstance.login(success: { [weak self] in
            SVProgressHUD.showSuccess(withStatus: "Logged in!")
            self?.performSegue(withIdentifier: "loginSegue", sender: nil)
        }, failure: { (error: Error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
}
