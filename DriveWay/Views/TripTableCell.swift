//
//  TripTableCell.swift
//  Driveway
//
//  Created by imac on 4/29/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

protocol TripTableCellDelegate {
    func onGetDirections(trip: BookContract)
    func onLeaveReview(trip: BookContract)
}
class TripTableCell : UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var btnGetDirection: UIButton!
    
    var delegate: TripTableCellDelegate?
    var trip: BookContract?
    
    @IBAction func onGetDirections(_ sender: Any) {
        if let trip = self.trip {
            if trip.isPast, !trip.hasReview {
                delegate?.onLeaveReview(trip: trip)
            } else {
                delegate?.onGetDirections(trip: trip)
            }
            
        }
    }
    
    func setData(trip: BookContract) {
        self.trip = trip
        
        if trip.isPast, !trip.hasReview {
            btnGetDirection.setTitle("LEAVE A REVIEW", for: .normal)
        } else {
            btnGetDirection.setTitle("GET DIRECTIONS", for: .normal)
        }
        
        lblTitle.text = trip.parkingSpot?.title
        
        if trip.isPast {
            lblDate.text = trip.dateTo.longTimeAgoSinceNow
        } else {
            let dateFromStr = trip.dateFrom.toString(format: "MMMM dd, yyyy")
            let dateToStr = trip.dateTo.toString(format: "MMMM dd, yyyy")
            
            lblDate.text = "\(dateFromStr) - \(dateToStr)"
        }
        
        if trip.bookType == .daily {
            lblTime.text = "Daily"
        } else {
            lblTime.text = "Hourly - From \(times[trip.hourFrom!]) to \(times[trip.hourTo!])"
        }
        
        imgPhoto.image = nil
        if let photoURL = trip.parkingSpot?.photosURLs[0] {
            imgPhoto.sd_setImage(with: URL(string: photoURL), completed: nil)
        }
    }
}
