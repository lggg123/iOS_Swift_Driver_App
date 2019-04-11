//
//  Booking.swift
//  Driveway
//
//  Created by imac on 5/22/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Firebase

class BookQuery {
    
    //location info
    var address: String?
    var city: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    
    var dateFrom: Date?
    var dateTo: Date?
    
    var type: BookType?
    var hourFrom: Int?
    var hourTo: Int?
    
}

enum BookStatus: String {
    case occupied = "occupied"
    case empty = "empty"
    case blocked = "blocked"
}

class BookingTimeEntry {
    var key: String
    
    var spotID: String
    var date: Date
    var type: BookType
    var hourFrom: Int?
    var hourTo: Int?
    var status: BookStatus
    var contractID: String
    
    init(spotID: String, date: Date, type: BookType, hourFrom: Int?, hourTo: Int?, status: BookStatus, contractID: String) {
        self.key = ""
        self.spotID = spotID
        self.date = date
        self.type = type
        self.hourFrom = hourFrom
        self.hourTo = hourTo
        self.status = status
        self.contractID = contractID
    }
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        self.key = snapshot.key
        
        guard let dic = snapshot.value as? [String: Any] else {
            return nil
        }
        
        guard let spotID = dic["spotID"] as? String,
            let dateStr = dic["date"] as? String,
            let hourFrom = dic["hourFrom"] as? Int,
            let hourTo = dic["hourTo"] as? Int,
            let typeStr = dic["type"] as? String,
            let type = BookType(rawValue: typeStr),
            let statusStr = dic["status"] as? String,
            let status = BookStatus(rawValue: statusStr),
            let contractID = dic["contractID"] as? String else {
                return nil
        }
        
        self.spotID = spotID
        self.hourFrom = hourFrom
        self.hourTo = hourTo
        self.type = type
        self.status = status
        self.contractID = contractID
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        if let date = formatter.date(from: dateStr) {
            self.date = date
        } else {
            return nil
        }
    }
    
    func save(completion: @escaping((Error?)->Void)) {
        let key = date.toKey()
        
        let firRef = ref().child("parkingSpots").child(spotID).child("books").child(key).childByAutoId()
        
        var dic:[String: Any] = [:]
        dic["date"] = key
        dic["spotID"] = spotID
        dic["type"] = type.rawValue
        if let hourFrom = self.hourFrom, let hourTo = self.hourTo {
            dic["hourFrom"] = hourFrom
            dic["hourTo"] = hourTo
        }
        dic["status"] = status.rawValue
        dic["contractID"] = contractID
        
        firRef.setValue(dic) { (error, ref) in
            completion(error)
        }
    }
    
    func remove(completion: @escaping((Error?)->Void)) {
        let dateKey = self.date.toKey()
        let firRef = ref().child("parkingSpots").child(spotID).child("books").child(dateKey).child(self.key)
        
        firRef.removeValue { (error, ref) in
            completion(error)
        }
        
    }
}

class BookContract {
    var contractID: String?
    
    let hostID: String
    let customerID: String
    let spotID: String
    let spotName: String
    
    let address: String
    let latitude: Double
    let longitude: Double
    
    let dateFrom: Date
    let dateTo: Date
    let bookType: BookType
    let hourFrom: Int?
    let hourTo: Int?
    let totalPrice: Double
    
    var updatedAt: Date
    
    var reviewID: String? = nil
    var chargeID: String? = nil //used for refunding
    
    //runtime variable
    var parkingSpot: ParkingSpot?
    var color: UIColor = UIColor.clear
    
    var isPast: Bool {
        let today = Date()
        
        return dateTo.compare(today) == .orderedAscending
    }
    
    var hasReview: Bool {
        return reviewID != nil
    }
    
    init(hostID: String, customerID: String, spotID: String, spotName: String, dateFrom: Date, dateTo: Date, bookType: BookType, hourFrom: Int?, hourTo: Int?, totalPrice: Double, address: String, latitude: Double, longitude: Double) {
        self.spotName = spotName
        self.hostID = hostID
        self.customerID = customerID
        self.spotID = spotID
        
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.bookType = bookType
        self.hourFrom = hourFrom
        self.hourTo = hourTo
        self.totalPrice = totalPrice
        
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        
        self.chargeID = nil
        
        self.updatedAt = Date()
    }
    func remove(completion: @escaping((Error?)->Void)) {
        let firRef = ref().child("contracts").child(self.contractID!)
        
        firRef.removeValue { (error, ref) in
            completion(error)
        }
    }
    func save(completion: @escaping((Error?, String?)->Void)){
        var firRef: DatabaseReference!
        
        if let key = self.contractID {
            firRef = ref().child("contracts").child(key)
        } else {
            firRef = ref().child("contracts").childByAutoId()
            self.contractID = firRef.key
        }
        
        var dic:[String: Any] = [:]
        dic["contractID"] = contractID!
        dic["hostID"] = hostID
        dic["customerID"] = customerID
        dic["spotID"] = spotID
        dic["spotName"] = spotName
        
        dic["dateFrom"] = dateFrom.toKey()
        dic["dateTo"] = dateTo.toKey()
        dic["bookType"] = bookType.rawValue
        
        if bookType == .hourly {
            dic["hourFrom"] = hourFrom!
            dic["hourTo"] = hourTo!
        }
        
        dic["totalPrice"] = totalPrice
        
        dic["address"] = address
        dic["latitude"] = latitude
        dic["longitude"] = longitude
        
        dic["updatedAt"] = updatedAt.toKey()
        
        if let chargeID = self.chargeID {
            dic["chargeID"] = chargeID
        }
        
        if let reviewID = self.reviewID {
            dic["reviewID"] = reviewID
        }
        
        
        firRef.setValue(dic) { (error, ref) in
            completion(error,  self.contractID)
        }
    }
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        guard let dic = snapshot.value as? [String: Any] else { return nil }
        
        guard let contractID = dic["contractID"] as? String,
            let hostID = dic["hostID"] as? String,
            let customerID = dic["customerID"] as? String,
            let spotID = dic["spotID"] as? String,
            let spotName = dic["spotName"] as? String,
            let dateFromStr = dic["dateFrom"] as? String,
            let dateToStr = dic["dateTo"] as? String,
            let bookTypeStr = dic["bookType"] as? String,
            let bookType = BookType(rawValue: bookTypeStr),
            let totalPrice = dic["totalPrice"] as? Double,
            let address = dic["address"] as? String,
            let latitude = dic["latitude"] as? Double,
            let longitude = dic["longitude"] as? Double,
            let updatedAtStr = dic["updatedAt"] as? String
            else {
                return nil
        }
        
        if bookType == .hourly {
            if let hourFrom = dic["hourFrom"] as? Int,
                let hourTo = dic["hourTo"] as? Int {
                self.hourFrom = hourFrom
                self.hourTo = hourTo
            } else {
                return nil
            }
        } else {
            self.hourFrom = nil
            self.hourTo = nil
        }
        
        self.contractID = contractID
        self.hostID = hostID
        self.customerID = customerID
        self.spotID = spotID
        self.spotName = spotName
        self.chargeID = dic["chargeID"] as? String
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        if let dateFrom = formatter.date(from: dateFromStr),
            let dateTo = formatter.date(from: dateToStr),
            let updatedAt = formatter.date(from: updatedAtStr){
            self.dateFrom = dateFrom
            self.dateTo = dateTo
            self.updatedAt = updatedAt
        } else {
            return nil
        }
        
        self.bookType = bookType
        self.totalPrice = totalPrice
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        
        self.reviewID = dic["reviewID"] as? String
        
    }
    
    static func loadContractsFor(customerID: String, completion:@escaping(([BookContract])->Void)) {
        let firRef = ref().child("contracts")
        
        firRef.queryOrdered(byChild: "customerID").queryEqual(toValue: customerID).observeSingleEvent(of: .value) { (snapshot) in
            var contracts:[BookContract] = []
            
            if snapshot.exists() {
                let children = snapshot.children
                
                while let child = children.nextObject() as? DataSnapshot {
                    if let contract = BookContract(snapshot: child) {
                        contracts.append(contract)
                    }
                }
            }
            completion(contracts)
        }
    }
    
    static func loadContractsFor(hostID: String, completion:@escaping(([BookContract])->Void)) {
        let firRef = ref().child("contracts")
        
        firRef.queryOrdered(byChild: "hostID").queryEqual(toValue: hostID).observeSingleEvent(of: .value) { (snapshot) in
            var contracts:[BookContract] = []
            
            if snapshot.exists() {
                let children = snapshot.children
                
                while let child = children.nextObject() as? DataSnapshot {
                    if let contract = BookContract(snapshot: child) {
                        contracts.append(contract)
                    }
                }
            }
            completion(contracts)
        }
    }
    
    func makeReview(rating: Double, content: String, completion:@escaping((Error?, String?)->())) {
        if let contractID = self.contractID {
            Review.makeReview(rating: rating, spotID: self.spotID, contractID: contractID, content: content, completion: { (error, reviewID) in
                if let reviewID = reviewID {
                    self.reviewID = reviewID
                    self.save(completion: { (error, key) in
                        completion(nil, reviewID)
                    })
                } else {
                    completion(error, nil)
                }
            })
        } else {
            completion(MyError.invalidUser(reason: "Contract id is invalid"), nil)
        }
    }
}
