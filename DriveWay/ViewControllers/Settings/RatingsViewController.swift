//
//  RatingsViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class RatingsViewController : UITableViewController {
    var spot: ParkingSpot!
    var reviews: [Review] = []
    
    static func newInst(spot: ParkingSpot) -> UIViewController {
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "ratingsvc") as! RatingsViewController
        
        vc.spot = spot
        
        return vc
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spot.reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ratingtc", for: indexPath) as! RatingTableCell
        let review = self.spot.reviews[indexPath.row]
        cell.setData(review: review)
        
        cell.selectionStyle = .none
        
        return cell
    }
}
