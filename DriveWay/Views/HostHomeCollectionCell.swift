//
//  ParkingSlotCollectionCell.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Cosmos

protocol HostHomeCollectionCellDelegate {
    func onOption(indexPath: IndexPath)
}
class HostHomeCollectionCell : UICollectionViewCell {
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var cosRate: CosmosView!
    @IBOutlet weak var lblReviews: UILabel!
    
    var delegate: HostHomeCollectionCellDelegate?
    var indexPath: IndexPath?
    
    func setData(spot: ParkingSpot) {
        lblName.text = spot.title
        cosRate.rating = spot.rating
        lblReviews.text = "\(spot.ratingsCount) Reviews"
        
        if let first = spot.photosURLs.first {
            imgPhoto.sd_setImage(with: URL(string: first), completed: nil)
        }
    }
    @IBAction func onOptionUp(_ sender: Any) {
        if let indexPath = self.indexPath {
            delegate?.onOption(indexPath: indexPath)
        }
    }
}
