//
//  SearchParkingViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import GooglePlaces
import GooglePlacePicker

class SearchParkingViewController : UIViewController {
    
    @IBOutlet weak var tfFrom: UITextField!
    @IBOutlet weak var tfTo: UITextField!
    
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnHourly: UIButton!
    
    @IBOutlet weak var tfLocation: UITextField!
    
    @IBOutlet weak var svHours: UIStackView!
    @IBOutlet weak var tfHourFrom: UITextField!
    @IBOutlet weak var tfHourTo: UITextField!
    
    
    var address: String?
    var city: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    
    
    var dateFrom: Date! = Date().addingTimeInterval(60 * 60 * 24) {
        didSet {
            let current = Calendar.current
            
            let year = current.component(.year, from: dateFrom)
            let month = current.component(.month, from: dateFrom)
            let day = current.component(.day, from: dateFrom)
            tfFrom.text = "\(month)/\(day)/\(year)"
            
        }
    }
    var dateTo: Date! = Date().addingTimeInterval(60 * 60 * 24) {
        didSet {
            let current = Calendar.current
            
            let year = current.component(.year, from: dateTo)
            let month = current.component(.month, from: dateTo)
            let day = current.component(.day, from: dateTo)
            
            tfTo.text = "\(month)/\(day)/\(year)"
        }
    }
    
    var bookType: BookType = .daily {
        didSet {
            btnDaily.isSelected = self.bookType == .daily
            btnHourly.isSelected = self.bookType == .hourly
            svHours.isHidden = !(self.bookType == .hourly)
        }
    }
    
    var hourFromIndex = 0 {
        didSet {
            tfHourFrom.text = times[hourFromIndex]
        }
    }
    var hourToIndex = 0 {
        didSet {
            tfHourTo.text = times[hourToIndex]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfLocation.delegate = self
        
        bookType = .hourly
        dateFrom = Date().addingTimeInterval(60 * 60 * 24)
        dateTo = Date().addingTimeInterval(60 * 60 * 24)
        setImageTitle()
        
        tfHourFrom.delegate = self
        tfHourTo.delegate = self
    }
    
    @IBAction func onSelectDateFrom(_ sender: Any) {
        let picker = ActionSheetDatePicker(title: "Select Date:", datePickerMode: .date, selectedDate: dateFrom, doneBlock: { (picker, date, origin) in
            if let date = date as? Date {
                self.dateFrom = date
                
                if self.dateFrom.compare(self.dateTo) == .orderedDescending {
                    self.dateTo = self.dateFrom
                }
            }
        }, cancel: { (picker) in
            
        }, origin: self.view)
        
        picker?.minimumDate = Date().addingTimeInterval(60 * 60 * 24)
        
        picker?.show()
    }
    
    @IBAction func onDaily(_ sender: Any) {
        self.bookType = .daily
    }
    
    @IBAction func onHourly(_ sender: Any) {
        self.bookType = .hourly
    }
    
    @IBAction func onSelectDateTo(_ sender: Any) {
        let picker = ActionSheetDatePicker(title: "Select Date:", datePickerMode: .date, selectedDate: dateTo, doneBlock: { (picker, date, origin) in
            if let date = date as? Date {
                self.dateTo = date
            }
        }, cancel: { (picker) in
            
        }, origin: self.view)
        
        picker?.minimumDate = dateFrom
        
        picker?.show()
    }
    @IBAction func onSearch(_ sender: Any) {
        guard let country = self.country,
            let city = self.city,
            let address = self.address,
            //let postalCode = self.postalCode,
            let lat = self.latitude,
            let lng = self.longitude else {
                self.alertOk(title: "Error", message: "Please input correct location", cancelButton: "OK", cancelHandler: nil)
                return
        }
        
        if bookType == .hourly {
            if hourFromIndex >= hourToIndex {
                self.alertOk(title: "Error", message: "You didn't select hours correctly, please try again", cancelButton: "OK", cancelHandler: nil)
                return
            }
        }
        
        let bookQuery :BookQuery = BookQuery()
        bookQuery.latitude = lat
        bookQuery.longitude = lng
        bookQuery.dateFrom = dateFrom
        bookQuery.dateTo = dateTo
        bookQuery.type = bookType
        bookQuery.hourFrom = hourFromIndex
        bookQuery.hourTo = hourToIndex
        
        let vc = MapViewController.newInst(bookQuery: bookQuery)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SearchParkingViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfLocation {
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePickerViewController(config: config)
            
            placePicker.delegate = self
            
            present(placePicker, animated: true, completion: nil)
            
            return false
        } else if textField == tfHourFrom {
            ActionSheetStringPicker.show(withTitle: "Select from:", rows: times, initialSelection: hourFromIndex, doneBlock: { (picker, index, origin) in
                self.hourFromIndex = index
            }, cancel: { (picker) in
                
            }, origin: self.view)
            
            return false
        } else if textField == tfHourTo {
            ActionSheetStringPicker.show(withTitle: "Select to:", rows: times, initialSelection: hourToIndex, doneBlock: { (picker, index, origin) in
                self.hourToIndex = index
            }, cancel: { (picker) in
                
            }, origin: self.view)
            
            return false
        }
        
        return true
    }
}

extension SearchParkingViewController : GMSPlacePickerViewControllerDelegate {
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
