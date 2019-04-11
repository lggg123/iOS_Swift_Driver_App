//
//  AddParkingPriceViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import SVProgressHUD
import ActionSheetPicker_3_0

class AddParkingPriceViewController : UIViewController {
    
    var spot: ParkingSpot!
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfPricePerDay: UITextField!
    @IBOutlet weak var tfPricePerHour: UITextField!
    
    @IBOutlet weak var btnDepositRequired: UIButton!
    @IBOutlet weak var btnDepositNotRequired: UIButton!
    @IBOutlet weak var tfDepositAmount: UITextField!
    
    @IBOutlet weak var btnDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfTitle.text = spot.title
        
        if spot.pricePerDay > 0 {
            tfPricePerDay.text = "\(spot.pricePerDay)"
        }
        
        if spot.pricePerHour > 0 {
            tfPricePerHour.text = "\(spot.pricePerHour)"
        }
        
        btnDepositRequired.isSelected = spot.depositRequired
        btnDepositNotRequired.isSelected = !spot.depositRequired
        
        if spot.depositAmount > 0 {
            tfDepositAmount.text = "\(spot.depositAmount)"
        }
    }
    var isDepositeRequired:Bool = false {
        didSet {
            btnDepositRequired.isSelected = isDepositeRequired
            btnDepositNotRequired.isSelected = !isDepositeRequired
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        let title = tfTitle.text!.trimmingCharacters(in: .whitespaces)
        
        if title == "" {
            self.alertOk(title: "Error", message: "Please input title", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        guard let pricePerDay = Double(tfPricePerDay.text!), pricePerDay > 0,
            let pricePerHour = Double(tfPricePerHour.text!), pricePerHour > 0
        else {
            self.alertOk(title: "Error", message: "Please input prices", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        
        if isDepositeRequired {
            if let depositAmount = Double(tfDepositAmount.text!) {
                spot.depositAmount = depositAmount
            } else {
                self.alertOk(title: "Error", message: "Please input deposit amount", cancelButton: "OK", cancelHandler: nil)
                return
            }
        }
        
        spot.title = title
        spot.pricePerDay = pricePerDay
        spot.pricePerHour = pricePerHour
        
        btnDone.isEnabled = false
        btnDone.sd_addActivityIndicator()
        self.btnDone.setTitle("", for: .normal)
        
        let isNew = spot.key == ""

        spot.save { (error) in
            self.btnDone.sd_removeActivityIndicator()
            self.btnDone.setTitle("Done", for: .normal)
            self.btnDone.isEnabled = true
            
            if let error = error {
                self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
            } else {
                if isNew {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }
        }
    }
    
    @IBAction func onDepositeRequired(_ sender: Any) {
        isDepositeRequired = true
        
    }
    
    @IBAction func onDepositeNotRequired(_ sender: Any) {
        isDepositeRequired = false
    }
    
    static func newInst(spot: ParkingSpot) -> UIViewController {
        let vc = UIStoryboard(name: "ParkingSpot", bundle: nil).instantiateViewController(withIdentifier: "addparkingpricevc") as! AddParkingPriceViewController
        vc.spot = spot
        
        return vc
    }
}
