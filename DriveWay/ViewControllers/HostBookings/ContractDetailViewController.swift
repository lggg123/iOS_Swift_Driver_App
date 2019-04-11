//
//  ContractDetailViewController.swift
//  Driveway
//
//  Created by imac on 5/29/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class ContractDetailViewController : UIViewController {
    
    var contract: BookContract!
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBookingDate: UILabel!
    @IBOutlet weak var lblSpotName: UILabel!
    @IBOutlet weak var lblBookTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setImageTitle()
        
        imgUser.loadImageFor(userID: contract.customerID)
        lblUserName.setNameFor(userID: contract.customerID, prefix: "")
        
        lblBookingDate.text = contract.updatedAt.toString(format: "MMMM dd, yyyy")
        lblSpotName.text = self.contract.spotName
        let type = (contract.bookType == .daily ? "daily" : "hourly \(times[contract.hourFrom!])-\([contract.hourTo!])")
        lblBookTime.text = "\(contract.dateFrom.toString(format: "MMMM dd, yyyy"))-\(contract.dateTo.toString(format: "MMMM dd, yyyy")) \(type)"
    }
    
    @IBAction func onSendChat(_ sender: Any) {
        gotoChatRoom(userID: contract.customerID)
    }
    
    @IBAction func onCancelBoking(_ sender: Any) {
        ParkingSpot.loadSpot(by: contract.spotID) { (spot) in
            if let spot = spot {
                spot.cancelBook(contract: self.contract, completion: { (error) in
                    if let error = error {
                        self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    static func newInst(contract: BookContract) -> UIViewController {
        let vc = UIStoryboard(name: "HostBookings", bundle: nil).instantiateViewController(withIdentifier: "contractdetailvc") as! ContractDetailViewController
        
        vc.contract = contract
        
        return vc
    }
}
