//
//  ChannelTableCell.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class ChannelTableCell : UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    //    @IBOutlet weak var imgNewMsgIndicator: UIImageView!
    
    var thisChannel : MsgChannel?
    var avatarDelegate: AvatarTouchDelegate?
    func setChannel(channel: MsgChannel) {
        self.thisChannel = channel
        
        imgUser.loadImageFor(userID: channel.userID)
        lblName.setNameFor(userID: channel.userID, prefix: "")
        
        self.lblMsg.text = channel.lastMsg
        self.lblTime.text = channel.time.toDate().shortTimeAgoSinceNow
        //        self.imgNewMsgIndicator.isHidden = channel.isRead
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar))
        self.imgUser.addGestureRecognizer(gr)
        self.imgUser.isUserInteractionEnabled = true
    }
    
    @objc func onTapAvatar() {
        if let channel = self.thisChannel, let _ = self.avatarDelegate{
            self.avatarDelegate!.onTapAvatar(for: channel.userID)
        }
    }

}
