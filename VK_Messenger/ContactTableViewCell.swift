//
//  ContactTableViewCell.swift
//  VK_Messenger
//
//  Created by Dima on 16/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var onlineStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
