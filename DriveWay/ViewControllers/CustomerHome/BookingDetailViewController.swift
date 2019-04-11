//
//  ParkingDetailViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class BookingDetailViewController : UIViewController {
    var spot: ParkingSpot!
    var bookQuery: BookQuery!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var tfFrom: UITextField!
    @IBOutlet weak var tfTo: UITextField!
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnHourly: UIButton!
    
    @IBOutlet weak var tfHourFrom: UITextField!
    @IBOutlet weak var tfHourTo: UITextField!
    @IBOutlet weak var svHours: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    
    func initUI() {
        lblTitle.text = spot.title
        lblUserName.setNameFor(userID: spot.userID, prefix: "Hosted by ")
        lblLocation.text = spot.address
        tfFrom.text = bookQuery.dateFrom?.toString(format: "MM/dd/yy")
        tfTo.text = bookQuery.dateTo?.toString(format: "MM/dd/yy")
        
        tfFrom.isEnabled = false
        tfTo.isEnabled = false
        btnHourly.isSelected = bookQuery.type == BookType.hourly
        btnDaily.isSelected = bookQuery.type == BookType.daily
        svHours.isHidden = !(bookQuery.type == BookType.hourly)
        
        if let hourFrom = bookQuery.hourFrom, let hourTo = bookQuery.hourTo {
            tfHourFrom.text = times[hourFrom]
            tfHourTo.text = times[hourTo]
        }
        tfHourFrom.isEnabled = false
        tfHourTo.isEnabled = false
    }
    
    @IBAction func onNext(_ sender: Any) {
        let vc = BookingPolicyViewController.newInst(spot: self.spot, bookQuery: self.bookQuery)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func newInst(spot: ParkingSpot, bookQuery: BookQuery) -> UIViewController {
        
        let vc = UIStoryboard(name: "CustomerHome", bundle: nil).instantiateViewController(withIdentifier: "bookingdetailvc") as! BookingDetailViewController
        vc.spot = spot
        vc.bookQuery = bookQuery
        
        return vc
    }
}
