//
//  BookingPolicyViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class BookingPolicyViewController : UIViewController {
    
    var spot: ParkingSpot!
    var bookQuery: BookQuery!
    
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblCancelPolicy: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI() {
        guard let dateFrom = bookQuery.dateFrom, let dateTo = bookQuery.dateTo, let hourFrom = bookQuery.hourFrom, let hourTo = bookQuery.hourTo, let bookType = bookQuery.type else {
            return
        }
        
        lblTerms.text = spot.terms
        lblCancelPolicy.text = spot.cancelPolicy
        let price = spot.price(bookQuery: self.bookQuery)
        
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: dateFrom, to: dateTo).day {
            if bookType == .daily {
        
                lblPrice.text = days == 0 ? "$\(price) for 1 day" : "$\(price) for \(days+1) days"
            } else {
                let hours = hourTo - hourFrom
                assert(hours >= 0)
                
                lblPrice.text = days == 0 ? "$\(price) for 1 day" : "$\(price) for \(days+1) days"
            }
        }
    }
    
    @IBAction func onAgree(_ sender: Any) {
        let vc = BookingPayViewController.newInst(spot: self.spot, bookQuery: self.bookQuery)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    static func newInst(spot: ParkingSpot, bookQuery: BookQuery) -> UIViewController {
        let vc = UIStoryboard(name: "CustomerHome", bundle: nil).instantiateViewController(withIdentifier: "bookingpolicyvc") as! BookingPolicyViewController
        
        vc.spot = spot
        vc.bookQuery = bookQuery
        
        return vc
    }
}
