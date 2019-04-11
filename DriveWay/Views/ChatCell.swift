//
//  ChatCell.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class ChatCell : UITableViewCell {
    @IBOutlet weak var lblMessage: UILabel!
//    @IBOutlet weak var imgMessage: UIImageView!
//    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    func setData(message: Message) {
        lblMessage.text = message.text
        imgUser.loadImageFor(userID: message.userID)
//        lblTime.text = message.time.toDate().longTimeAgoSinceNow
        
        
//        if let url = message.image, let urlObj = URL(string: url) {
//            imgMessage.sd_setImage(with: urlObj, completed: nil)
//            imgMessage.isHidden = false
//        } else {
//            imgMessage.isHidden = true
//        }
    }
}
