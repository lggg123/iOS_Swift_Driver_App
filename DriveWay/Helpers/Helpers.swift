//
//  Helpers.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import SDWebImage
import SwiftyJSON
import GeoFire

func gotoViewController(id: String, storyboardName: String = "Main") {
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    
    if id == "home" {
        let tabbarController = storyboard.instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
        
        UIApplication.shared.delegate?.window??.rootViewController = tabbarController
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    } else {
        let nav = storyboard.instantiateViewController(withIdentifier: id)
        UIApplication.shared.delegate?.window??.rootViewController = nav
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    }
}

func isNameValid(name: String) -> Bool {
    let nameRegex = "[A-Za-z][A-Za-z\\s]*"
    let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
    return nameTest.evaluate(with: name)
}

func isEmailValid(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: email)
}

//accepts only letters, spaces and special characters only
func isTitleValid(title: String) -> Bool {
    let titleRegex = "[A-Za-z.,\\?'_%+\\-!@$&():;/\"\\s]*"
    let titleTest = NSPredicate(format: "SELF MATCHES %@", titleRegex)
    return titleTest.evaluate(with: title)
}

func curid() -> String? {
    return Auth.auth().currentUser?.uid
}

func curuser() -> Firebase.User? {
    return Auth.auth().currentUser
}

func ref() -> DatabaseReference {
    return Database.database().reference()
}

func geo() -> GeoFire {
    return GeoFire(firebaseRef: ref())
}

func sref() -> StorageReference {
    let storageURL = FirebaseApp.app()?.options.storageBucket
    return Storage.storage().reference(forURL: "gs://" + storageURL!)
}

func uploadImageTo( path: String, image: UIImage!, completionHandler: @escaping (_ downloadURL: String?, _ error: Error?)->()) {
    let data = UIImagePNGRepresentation(image)
    let metaData = StorageMetadata()
    metaData.contentType = "image/png"
    
    sref().child(path).putData(data!, metadata: metaData) { (metadata, error) in
        if let error = error {
            completionHandler(nil, error)
            return
        }
        
        if let path = metadata?.path {
            let gsPath = sref().child(path).description
            let gsRef = Storage.storage().reference(forURL: gsPath)
            
            gsRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    completionHandler(url!.absoluteString, nil)
                }
            })
        } else {
            completionHandler(nil, MyError.downloadURL(reason: "Can not download image"))
        }
    }
}

func timestamp() -> String {
    return "\(NSDate().timeIntervalSince1970*1000)"
}


func openURL(linkURL:String) {
    let url = URL(string: linkURL)!
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
    guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
        completion(false)
        return
    }
    guard #available(iOS 10, *) else {
        completion(UIApplication.shared.openURL(url))
        return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: completion)
}

//func checkLocatioPermission() -> Bool {
//    if CLLocationManager.locationServicesEnabled() {
//        switch(CLLocationManager.authorizationStatus()) {
//        case .notDetermined, .restricted, .denied:
//            return false
//        case .authorizedAlways, .authorizedWhenInUse:
//            return true
//        }
//    } else {
//        return false
//    }
//}


func geocode(placeID: String, completion:@escaping (_ city: String?,_ country:  String?, _ postalCode: String?)->()) {
    let url = "https://maps.googleapis.com/maps/api/geocode/json"
    let parameters = [ "place_id": placeID, "key":googlePlaceServerAPIKey]
    
    Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
        
        switch response.result {
        case .success(let val):
            
            let json = JSON(val)
            
            if let results = json["results"].array, results.count > 0 {
                var city: String?
                var postalCode: String?
                var country: String?
                
                let addresses = results[0]["address_components"]
                for address in addresses.arrayValue {
                    if address["types"][0] == "locality" || address["types"][1] == "locality" {
                        city = address["short_name"].string
                    } else if address["types"][0] == "administrative_area_level_1" || address["types"][1] == "administrative_area_level_1" {
                        city = address["long_name"].string
                    }
                    
                    if address["types"][0] == "postal_code"{
                        postalCode = address["long_name"].string
                    }
                    
                    if address["types"][0] == "country" {
                        country = address["long_name"].string
                    }
                }
                
                completion(city, country, postalCode)
                
                return
                
            }
            completion(nil, nil, nil)
            
        case .failure(_):
            completion(nil, nil, nil)
        }
    }
    
}


