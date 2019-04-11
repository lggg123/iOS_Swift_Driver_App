//
//  AddParkingTimeViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import SVProgressHUD
import GooglePlaces
import GooglePlacePicker
import ActionSheetPicker_3_0


class AddParkingTimeViewController : UIViewController {
    
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnHourly: UIButton!
    @IBOutlet weak var tfLocation: UITextField!
    @IBOutlet weak var tfHourFrom: UITextField!
    @IBOutlet weak var tfHourTo: UITextField!

    @IBOutlet weak var svHours: UIStackView!
    var country: String?
    var city: String?
//    var postalCode: String?
    var address: String?
    
    var latitude: Double?
    var longitude: Double?
    
    var fromIndex = 0
    var toIndex = 0
    
    var spot:ParkingSpot?

    var bookType : BookType = .hourly {
        didSet {
            btnDaily.isSelected = (bookType == .daily)
            btnHourly.isSelected = (bookType == .hourly)
            
            svHours.isHidden = !btnHourly.isSelected
        }
    }
    
    @IBAction func onDaily(_ sender: Any) {
        self.bookType = .daily
    }
    
    @IBAction func onHourly(_ sender: Any) {
        self.bookType = .hourly
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfLocation.delegate = self
        tfHourFrom.delegate = self
        tfHourTo.delegate = self
        
        if let spot = self.spot {
            country = spot.country
            city = spot.city
            address = spot.address
            latitude = spot.latitude
            longitude = spot.longitude
            
            fromIndex = spot.availableHourFrom
            toIndex = spot.availableHourTo
            
            tfLocation.text = address
            
            self.bookType = spot.bookType
            
            tfHourFrom.text = times[fromIndex]
            tfHourTo.text = times[toIndex]
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        guard let country = self.country,
            let city = self.city,
            let address = self.address,
//            let postalCode = self.postalCode,
            let lat = self.latitude,
            let lng = self.longitude else {
                self.alertOk(title: "Error", message: "Please input correct location", cancelButton: "OK", cancelHandler: nil)
                return
        }
        
        let spot: ParkingSpot = self.spot == nil ? ParkingSpot() : self.spot!
        
        if bookType == .hourly {
            if fromIndex >= toIndex {
                self.alertOk(title: "Error", message: "You didn't select hours correctly, please try again", cancelButton: "OK", cancelHandler: nil)
                return
            }
            spot.availableHourFrom = self.fromIndex
            spot.availableHourTo = self.toIndex
        }
        
        spot.country = country
        spot.city = city
        spot.latitude = lat
        spot.longitude = lng
        spot.address = address
        spot.bookType = bookType
        
        
        let vc = AddParkingPhotoViewController.newInst(spot: spot)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func newInst(spot: ParkingSpot?) -> UIViewController {
        let vc = UIStoryboard(name: "ParkingSpot", bundle: nil).instantiateViewController(withIdentifier: "addparkingtimevc") as! AddParkingTimeViewController
        vc.spot = spot
        
        return vc
    }
}

extension AddParkingTimeViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfLocation {
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePickerViewController(config: config)
            
            placePicker.delegate = self
            
            present(placePicker, animated: true, completion: nil)
            
            return false
        } else if textField == tfHourFrom  {
            ActionSheetStringPicker.show(withTitle: "Select Time", rows: times, initialSelection: fromIndex, doneBlock: { (picker, index, view) in
                
                self.tfHourFrom.text = times[index]
                self.fromIndex = index
            }, cancel: { (picker) in
                
            }, origin: self.view)
            return false
        } else if textField == tfHourTo {
            ActionSheetStringPicker.show(withTitle: "Select Time", rows: times, initialSelection: toIndex, doneBlock: { (picker, index, view) in
                
                self.tfHourTo.text = times[index]
                self.toIndex = index
            }, cancel: { (picker) in
                
            }, origin: self.view)
            return false
        }
        
        return true
    }
}

extension AddParkingTimeViewController : GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        if let address = place.formattedAddress {
            self.tfLocation.text = address
            let placeID = place.placeID
            
            latitude = place.coordinate.latitude
            longitude = place.coordinate.longitude
            self.address = address
            
            geocode(placeID: placeID, completion: { (city, country, postalCode) in
                print("city: \(city ?? ""), country:\(country ?? "")")
                
                self.city = city
                self.country = country
//                self.postalCode = postalCode
            })
            
            
            print("Open status", place.openNowStatus.rawValue)
        } else {
            self.alertOk(title: "Error", message: "Could not decode address from the location", cancelButton: "OK", cancelHandler: nil)
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}
