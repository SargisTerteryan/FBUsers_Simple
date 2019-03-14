//
//  UserTableViewCell.swift
//  FBUsers
//
//  Created by Saqo on 1/27/19.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {

    static let ProfilePlaceholder = "profile_placeholder"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureUserCell(user: UserModel) {
        let imageUrl = URL(string: user.imageUrl)
        let placeholderImage = UIImage(named: UserTableViewCell.ProfilePlaceholder)
        profileImageView.kf.setImage(with: imageUrl, placeholder: placeholderImage)
        
        fullNameLabel.text = user.fullName
    }
    
}
