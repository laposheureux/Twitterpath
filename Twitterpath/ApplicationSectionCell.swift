//
//  ApplicationSectionCell.swift
//  Twitterpath
//
//  Created by Aaron on 11/7/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit

class ApplicationSectionCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var label: UILabel!
    var iconImage: UIImage? {
        didSet {
            if let iconImage = iconImage {
                iconView.image = iconImage
            } else {
                iconView.image = nil
            }
        }
    }
}
