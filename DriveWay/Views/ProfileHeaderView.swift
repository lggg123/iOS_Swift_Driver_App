//
//  ProfileHeaderView.swift
//  Driveway
//
//  Created by imac on 4/28/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit

class ProfileHeaderView : UICollectionReusableView {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblMemberSince: UILabel!
    
    @IBOutlet weak var lblNumSpots: UILabel!
    
    func setData(user: User, spotsCount: Int) {
        imgUser.loadImageFor(userID: user.userID)
        lblName.setNameFor(userID: user.userID, prefix: "")
        lblDesc.text = user.about
        if let since = user.createdAt {
            lblMemberSince.text = "Member Since \(since.toDate().toString(format: "MMMM yyyy"))"
        } else {
            lblMemberSince.text = ""
        }
        
        
        lblNumSpots.text = spotsCount <= 1 ? "\(spotsCount) Parking Spot" : "\(spotsCount) Parking Spots"
    }
}
