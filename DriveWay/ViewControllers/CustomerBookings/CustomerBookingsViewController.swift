//
//  CustomerBookingsViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Cosmos

class CustomerBookingsViewController : UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var viRating: UIView!
    @IBOutlet weak var viRatingBack: UIView!
    
    @IBOutlet weak var cosRating: CosmosView!
    @IBOutlet weak var tvReview: UITextView!
    
    var trips: [BookContract] = []
    
    var tripForReview: BookContract? = nil
    
    var futureTrips: [BookContract] = [] {
        didSet {
            table.reloadData()
        }
        
    }
    
    var previousTrips: [BookContract] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageTitle()
        
        table.delegate = self
        table.dataSource = self
        
        viRating.isHidden = true
        
        let tapRatingContainer = UITapGestureRecognizer(target: self, action: #selector(self.onCancelRating))
        viRatingBack.isUserInteractionEnabled = true
        viRatingBack.addGestureRecognizer(tapRatingContainer)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTrips()
    }
    
    func loadTrips() {
        guard let userID = thisUser?.userID else { return }
        BookContract.loadContractsFor(customerID: userID) { (contracts) in
            self.trips = contracts
            
            let group = DispatchGroup()
            
            for trip in self.trips {
                group.enter()
                ParkingSpot.loadSpot(by: trip.spotID, completion: { (spot) in
                    trip.parkingSpot = spot
                    group.leave()
                })
            }
            
            group.notify(queue: .main, execute: {
                self.futureTrips = self.trips.filter({!$0.isPast})
                self.previousTrips = self.trips.filter({$0.isPast})
            })
        }
    }

    @objc func onCancelRating() {
        viRating.isHidden = true
        tvReview.text = ""
        self.tripForReview = nil
    }
    
    @IBAction func onPostReview(_ sender: Any) {
        
        
        let rating = cosRating.rating
        let review = tvReview.text!
        
        self.tripForReview?.makeReview(rating: rating, content: review, completion: { (error, key) in
            if let error = error {
                self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
            } else {
                self.viRating.isHidden = true
                self.tvReview.text = ""
                self.tripForReview = nil
                
                self.table.reloadData()
            }
        })
    }
    
}

extension CustomerBookingsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Future Trips"
        } else {
            return "Previous Trips"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return futureTrips.count
        } else {
            return previousTrips.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "triptc", for: indexPath) as! TripTableCell
        let trip: BookContract!
        
        if indexPath.section == 0 {
            trip = futureTrips[indexPath.row]
        } else {
            trip = previousTrips[indexPath.row]
        }
        
        cell.delegate = self
        cell.setData(trip: trip)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip: BookContract!
        
        if indexPath.section == 0 {
            trip = futureTrips[indexPath.row]
        } else {
            trip = previousTrips[indexPath.row]
        }
        
        if let spot = trip.parkingSpot {
            let vc = ParkingDetailViewController.newInst(spot: spot)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func openGoogleMaps(latitude: Double, longitude: Double) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
        } else {
            //            alertOk(title: "GoogleMaps", message: "Please install Google Maps", cancelButton: "OK", cancelHandler: nil)
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Parking Spot" //venue.name
            mapItem.openInMaps(launchOptions: options)
        }
    }
}

extension CustomerBookingsViewController : TripTableCellDelegate {
    func onGetDirections(trip: BookContract) {
        let latitude = trip.latitude
        let longitude = trip.longitude
        
        openGoogleMaps(latitude: latitude, longitude: longitude)
    }
    
    func onLeaveReview(trip: BookContract) {
        self.tripForReview = trip
        
        self.viRating.isHidden = false
    }
}
