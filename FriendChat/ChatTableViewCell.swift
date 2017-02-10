//
//  ChatTableViewCell.swift
//  FriendChat
//
//  Created by 黃毓皓 on 2017/2/10.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chat2: UITextView!
    @IBOutlet weak var chat1: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
