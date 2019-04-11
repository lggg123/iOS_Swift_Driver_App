//
//  MessageTableCell.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit

class MessageTableCell : UITableViewCell {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var viContainer: UIView!
    func setData(message: Message) {
        lblMessage.text = message.text
        
        lblTime.text = message.time.toDate().longTimeAgoSinceNow
        if message.isMine {
            viContainer.backgroundColor = primaryColor
        } else {
            viContainer.backgroundColor = UIColor.groupTableViewBackground
        }
        
        if let url = message.image, let urlObj = URL(string: url) {
            imgMessage.sd_setImage(with: urlObj, completed: nil)
            imgMessage.isHidden = false
        } else {
            imgMessage.isHidden = true
        }
    }
}

