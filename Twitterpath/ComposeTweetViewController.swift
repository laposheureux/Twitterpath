//
//  ComposeTweetViewController.swift
//  Twitterpath
//
//  Created by Aaron L'Heureux on 10/31/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeTweetViewController: UIViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var screenname: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var tweetButton: UIBarButtonItem!
    @IBOutlet var charactersLeft: UIBarButtonItem!

    let characterCount: Int = 140
    weak var delegate: TweetInjectable?

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self

        if let currentUser = TwitterUser.currentUser {
            name.text = currentUser.name
            screenname.text = currentUser.screenname
            if let currentUserImageURL = currentUser.profileImageURL {
                profileImageView.setImageWith(currentUserImageURL)
            } else {
                profileImageView.image = #imageLiteral(resourceName: "ProfilePlaceholder")
            }
        }

        textView.text = ""
        charactersLeft.title = "140"
        textView.becomeFirstResponder()
    }

    @IBAction func submitTweet(_ sender: UIBarButtonItem) {
        if let currentUser = TwitterUser.currentUser {
            let tweet = TwitterTweet(text: textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), timestamp: Date.init(), user: currentUser)

            SVProgressHUD.show()

            TwitterAPI.sharedInstance.submitTweet(tweet: tweet, success: { [weak self] in
                SVProgressHUD.dismiss()
                self?.delegate?.newTweet(tweet: tweet)
                self?.navigationController?.popViewController(animated: true)
            }, failure: { (error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            })
        } else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("There appears to be an issue with your account, try signing out and back in again.", comment: ""))
        }
    }
}

extension ComposeTweetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let whitespaceTrimmedText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        tweetButton.isEnabled = whitespaceTrimmedText.characters.count > 0 && whitespaceTrimmedText.characters.count <= 140
        charactersLeft.title = "\(140 - whitespaceTrimmedText.characters.count)"
    }
}
