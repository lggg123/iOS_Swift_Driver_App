//
//  AddParkingPolicyViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class AddParkingPolicyViewController : UIViewController {
    @IBOutlet weak var tvAbout: UITextView!
    @IBOutlet weak var tvTerms: UITextView!
    @IBOutlet weak var tvCancelPolicy: UITextView!
    
    var spot:ParkingSpot!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvAbout.text = spot.about
        self.tvTerms.text = spot.terms
        self.tvCancelPolicy.text = spot.cancelPolicy
    }
    
    static func newInst(spot: ParkingSpot) -> UIViewController {
        let vc = UIStoryboard(name: "ParkingSpot", bundle: nil).instantiateViewController(withIdentifier: "addparkingpolicyvc") as! AddParkingPolicyViewController
        
        vc.spot = spot
        
        return vc
    }
    
    @IBAction func onNext(_ sender: Any) {
        let about = self.tvAbout.text!
        let terms = self.tvTerms.text!
        let cancelPolicy = self.tvCancelPolicy.text!
        
        
        spot.about = about
        spot.terms = terms
        spot.cancelPolicy = cancelPolicy
        
        let vc = AddParkingPriceViewController.newInst(spot: self.spot)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
