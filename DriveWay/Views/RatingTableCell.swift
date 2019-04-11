//
//  RatingTableCell.swift
//  Driveway
//
//  Created by imac on 4/29/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class RatingTableCell : UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var cosRating: CosmosView!
    @IBOutlet weak var lblReview: UILabel!
    
    
    func setData(review: Review) {
        imgUser.loadImageFor(userID: review.reviewerID)
        cosRating.rating = review.rating
        lblReview.text = review.content
    }
}
