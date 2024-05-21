//
//  userlistTableViewCell.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 17/05/24.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var editAction: (() -> Void)?
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        editAction?()
    }
}
