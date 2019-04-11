//
//  MapViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController : UIViewController {
    
    @IBOutlet weak var map: GMSMapView!
    
    var spots: [ParkingSpot] = [] {
        didSet {
            refresh()
        }
    }
    
    var bookQuery: BookQuery!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setImageTitle()
        
        map.delegate = self
        map.isMyLocationEnabled = true
        
        //init location manager
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        loadSpots()
        
        if let latitude = bookQuery.latitude, let longitude = bookQuery.longitude {
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14)
            map.camera = camera
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    static func newInst(bookQuery: BookQuery) -> UIViewController {
        let vc = UIStoryboard(name: "CustomerHome", bundle: nil).instantiateViewController(withIdentifier: "mapvc") as! MapViewController
        vc.bookQuery = bookQuery
        
        return vc
    }
    
    func loadSpots() {
        ParkingSpot.searchParkingSpots(near: self.bookQuery.latitude!, longitude: self.bookQuery.longitude!) { (spots) in
            self.spots = spots.filter({$0.checkBookable(bookQuery: self.bookQuery)})
        }
    }
    
    func refresh() {
        self.map.clear()
        
        for spot in self.spots {
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude))
            marker.map = self.map
            
            let markerView : BalloonMarker = .fromNib()
            markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
            
            
            let price = spot.price(bookQuery: self.bookQuery)
            markerView.lblPrice.text = "$\(price.clean)"
            
            marker.map = self.map
            marker.iconView = markerView
            marker.userData = spot
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location {
            let marker = GMSMarker()
            marker.position = location.coordinate
            
            
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let spot = marker.userData as? ParkingSpot {
            let vc = ParkingDetailViewController.newInst(spot: spot, bookQuery: self.bookQuery)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return true
    }
}
