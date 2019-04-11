//
//  ParkingSpotCollectionCell.swift
//  Driveway
//
//  Created by imac on 6/13/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Cosmos

class ParkingSpotCollectionCell : UICollectionViewCell {
    @IBOutlet weak var imgSpot: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var cosRating: CosmosView!
    
    @IBOutlet weak var lblReviews: UILabel!
    
    func setData(spot: ParkingSpot) {
        if let url = spot.photosURLs.first {
            imgSpot.sd_setImage(with: URL(string: url), completed: nil)
        } else {
            imgSpot.image = nil
        }
        lblName.text = spot.title
        cosRating.rating = spot.rating
        lblReviews.text = spot.reviews.count == 1 ? "1 Review" : "\(spot.reviews.count) Reviews"
        
    }
}
