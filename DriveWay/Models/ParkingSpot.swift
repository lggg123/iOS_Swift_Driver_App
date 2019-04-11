//
//  ParkingSpot.swift
//  Driveway
//
//  Created by imac on 5/15/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//


import Firebase
import CoreLocation
import GeoFire

class ParkingSpot {
    var key: String = ""
    
    var userID: String = ""
    var address: String = ""
    var country: String = ""
    var city: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    var bookType: BookType = .hourly
    var availableHourFrom: Int = 0
    var availableHourTo: Int = 0
    
    var photosURLs: [String] = []
    
    var about: String = ""
    var terms: String = ""
    var cancelPolicy: String = ""
    
    var title: String = ""
    var pricePerDay: Double = 0
    var pricePerHour: Double = 0
    
    var depositRequired: Bool = false
    var depositAmount: Double = 0
    
    var reviews:[Review] = []
    
    var books: [String:[BookingTimeEntry]] = [:]
    
    //runtime variables
    var photos: [UIImage] = [] //used when only uploading
    var rating: Double = 0
    var ratingsCount: Int = 0
    
    func distance(from latitude: Double, longitude: Double) -> Double
    {
        
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let dist = thisLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        return Double(dist / 1000.00)
    }
    
    func distanceInMiles(from latitude: Double, longitude: Double) -> Double
    {
        
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let dist = thisLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        return Double(dist / 1609.34)
    }
    
    func isBlocked(date: Date) -> Bool {
        let key = date.toKey()
        
        if let entries = self.books[key] {
            for entry in entries {
                if entry.status == .blocked {
                    return true
                }
            }
        }
        
        return false
    }
    
    func block(date: Date, completion:@escaping((Error?)->Void)) {
        let entry = BookingTimeEntry(spotID: self.key, date: date, type: .daily, hourFrom: 0, hourTo: 0, status: .blocked, contractID: "")
        let key = date.toKey()
        if let _ = books[key] {
            books[key]!.append(entry)
        } else {
            books[key] = [entry]
        }
        entry.save { (error) in
            completion(error)
        }
    }
    
    func checkBookable(bookQuery: BookQuery) -> Bool {
        guard let dateFrom = bookQuery.dateFrom,
            let dateTo = bookQuery.dateTo,
            let type = bookQuery.type else {
            return false
        }
        
//        if self.bookType != type {
//            return false
//        }
        
        var date = dateFrom
        let calendar = Calendar.current
        let books = self.books
        
        if type == .hourly {
            let queryHourFrom = bookQuery.hourFrom!
            let queryHourTo = bookQuery.hourTo!
            
            if self.bookType == .hourly {
                if queryHourFrom < availableHourFrom {
                    return false
                }
                
                if queryHourTo > availableHourTo {
                    return false
                }
            } else {
                //if parking spot is daily available, fall through
            }
        } else {
            if self.bookType == .hourly {
                //could not book daily for hourly available parking spot
                return false
            }
        }
        
        while dateTo.compare(date) != .orderedAscending {
            let key = date.toKey()
            
            if let entries = books[key] {
                for entry in entries {
                    if entry.status == .blocked {
                        return false
                    }
                    
                    if entry.status == .occupied {
                        if entry.type == .daily {
                            return false
                        } else {
                            let queryHourFrom = bookQuery.hourFrom!
                            let queryHourTo = bookQuery.hourTo!
                            
                            if entry.hourFrom! <= queryHourFrom, queryHourFrom < entry.hourTo! {
                                return false
                            }
                            
                            if entry.hourFrom! < queryHourTo, queryHourTo <= entry.hourTo! {
                                return false
                            }
                        }
                    }
                }
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return true
    }
    
    func firRef() -> DatabaseReference {
        return ref().child("parkingSpot").child(key)
    }
    
    func cancelBook(contract: BookContract, completion:@escaping((Error?)->Void)) {
        var date = contract.dateFrom
        let calendar = Calendar.current
        
        while contract.dateTo.compare(date) != .orderedAscending {
            let key = date.toKey()
            
            if let entries = books[key] {
                for entry in entries {
                    if entry.contractID == contract.contractID {
                        entry.remove(completion: { (error) in
                            print(error?.localizedDescription ?? "")
                        })
                    }
                }
            }
           
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        contract.remove { (error) in
            completion(error)
        }
    }
    
    func book(bookQuery: BookQuery, completion: @escaping((Error?, BookContract?)->Void)) {
        guard let dateFrom = bookQuery.dateFrom,
            let dateTo = bookQuery.dateTo,
            let type = bookQuery.type else {
                print("Critical Error!")
                return
        }
        
        var date = dateFrom
        let calendar = Calendar.current
        var books = self.books
        
        let myUserID = thisUser!.userID
        let totalPrice = self.price(bookQuery: bookQuery)
        let contract = BookContract(hostID: self.userID, customerID: myUserID, spotID: self.key, spotName: self.title, dateFrom: dateFrom, dateTo: dateTo, bookType: type, hourFrom: bookQuery.hourFrom, hourTo: bookQuery.hourTo, totalPrice: totalPrice, address: self.address, latitude: self.latitude, longitude: self.longitude)
        
        contract.save { (error, contractID) in
            if let error = error {
                completion(error, nil)
            } else {
                let group = DispatchGroup()
                
                while dateTo.compare(date) != .orderedAscending {
                    let key = date.toKey()
                    let entry = BookingTimeEntry(spotID: self.key, date: date, type: type, hourFrom: bookQuery.hourFrom, hourTo: bookQuery.hourTo, status: .occupied, contractID: contractID!)
                    
                    if let _ = books[key] {
                        books[key]!.append(entry)
                    } else {
                        books[key] = [entry]
                    }
                    
                    
                    
                    group.enter()
                    entry.save(completion: { (error) in
                        group.leave()
                    })
                    
                    date = calendar.date(byAdding: .day, value: 1, to: date)!
                }
                
                group.notify(queue: .main, execute: {
                    completion(nil, contract)
                })
            }
        }
    }
    
    func price(bookQuery: BookQuery) -> Double {
        guard let dateFrom = bookQuery.dateFrom, let dateTo = bookQuery.dateTo, let hourFrom = bookQuery.hourFrom, let hourTo = bookQuery.hourTo else {
            print("invalid booking data for price calculation")
            return 0
        }
        
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: dateFrom, to: dateTo).day {
            if bookType == .daily {
                return Double(days + 1) * self.pricePerDay
            } else {
                let hours = hourTo - hourFrom
                assert(hours >= 0)
                
                return Double(days + 1) * Double(hours) * self.pricePerHour
            }
            
        } else {
            print("Invalid case. Days between \(dateFrom) \(dateTo)?")
            return 0
        }
    }
    
    init() {
    }
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        guard let dic = snapshot.value as? [String: Any] else {
            return nil
        }
        
        key = snapshot.key
        
        guard let title = dic["title"] as? String,
            let userID = dic["userID"] as? String,
            let address = dic["address"] as? String,
            let country = dic["country"] as? String,
            let city = dic["city"] as? String,
            let latitude = dic["latitude"] as? Double,
            let longitude = dic["longitude"] as? Double,
            let bookTypeStr = dic["bookType"] as? String,
            let bookType = BookType(rawValue: bookTypeStr),
            let about = dic["about"] as? String,
            let terms = dic["terms"] as? String,
            let cancelPolicy = dic["cancelPolicy"] as? String,
            let pricePerDay = dic["pricePerDay"] as? Double,
            let pricePerHour = dic["pricePerHour"] as? Double,
            let depositRequired = dic["depositRequired"] as? Bool else {
                return nil
        }
        
        self.title = title
        self.userID = userID
        self.address = address
        self.country = country
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.bookType = bookType
        self.about = about
        self.terms = terms
        self.cancelPolicy = cancelPolicy
        self.pricePerDay = pricePerDay
        self.pricePerHour = pricePerHour
        self.depositRequired = depositRequired

        if bookType == .hourly {
            if let hourFrom = dic["hourFrom"] as? Int,
                let hourTo = dic["hourTo"] as? Int {
                self.availableHourFrom = hourFrom
                self.availableHourTo = hourTo
            } else {
                return nil
            }
        }
        
        if depositRequired {
            if let depositAmount = dic["depositAmount"] as? Double{
                self.depositAmount = depositAmount
            } else {
                return nil
            }
        }
    
        self.photosURLs = dic["photos"] as? [String] ?? []
        
        let children = snapshot.childSnapshot(forPath: "reviews").children
        
        reviews = []

        var sum: Double = 0
        ratingsCount = 0
        while let child = children.nextObject() as? DataSnapshot {
            if let review = Review(snapshot: child) {
                reviews.append(review)
                
                sum += review.rating
                ratingsCount += 1
            }
        }
        
        rating = (ratingsCount == 0 ? 0 : sum / Double(ratingsCount))
        
        let booksChildren = snapshot.childSnapshot(forPath: "books").children
        books = [:]
        
        while let yearSnap = booksChildren.nextObject() as? DataSnapshot {
            if yearSnap.exists() {
                let yearChildren = yearSnap.children
                
                while let monthSnap = yearChildren.nextObject() as? DataSnapshot {
                    let monthChildren = monthSnap.children
                    
                    if !monthSnap.exists() { continue }
                    
                    while let daySnap = monthChildren.nextObject() as? DataSnapshot {
                        
                        if daySnap.exists() {
                            let key = "\(yearSnap.key)/\(monthSnap.key)/\(daySnap.key)"
                            
                            let children = daySnap.children
                            
                            var entries: [BookingTimeEntry] = []
                            while let child = children.nextObject() as?  DataSnapshot {
                                if let entry = BookingTimeEntry(snapshot: child) {
                                    entries.append(entry)
                                }
                            }
                            
                            books[key] = entries
                        }
                    }
                }
            }
            
        }
    }
    
    func save(completion:@escaping((Error?)->())) {
        
        let firRef = (key == "" ? ref().child("parkingSpots").childByAutoId() : ref().child("parkingSpots").child(key))
        
        guard let userID = thisUser?.userID else {
            completion(MyError.invalidUser(reason: "No user logged in"))
            return
        }
        
        self.key = firRef.key
        
        var dic:[String:Any] = [:]
        
        dic["title"] = self.title
        dic["userID"] = userID
        dic["address"] = self.address
        dic["country"] = self.country
        dic["city"] = self.city
        dic["latitude"] = self.latitude
        dic["longitude"] = self.longitude
        dic["bookType"] = self.bookType.rawValue
        dic["about"] = self.about
        dic["terms"] = self.terms
        dic["cancelPolicy"] = self.cancelPolicy
        dic["pricePerDay"] = self.pricePerDay
        dic["pricePerHour"] = self.pricePerHour
        dic["depositRequired"] = self.depositRequired
        
        if bookType == .hourly {
            dic["hourFrom"] = self.availableHourFrom
            dic["hourTo"] = self.availableHourTo
        }
        
        if depositRequired {
            dic["depositAmount"] = self.depositAmount
        }
        
        let group = DispatchGroup()
        
        group.enter()
        
        var i = 0
        var downloadURLs:[String] = []
        
        for image in self.photos {
            group.enter()
            
            let path = "parkingSpots/\(firRef.key)/image\(i)"
            uploadImageTo(path: path, image: image, completionHandler: { (downloadURL, error) in
                if let url = downloadURL {
                    downloadURLs.append(url)
                }
                
                group.leave()
            })
            
            i += 1
        }
        
        group.notify(queue: .main) {
            dic["photos"] = downloadURLs
           
            firRef.updateChildValues(dic, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    
                    self.update(location: CLLocation(latitude: self.latitude, longitude: self.longitude), completion: { (error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                }
                completion(error)
            })
        }
        group.leave()
    }
    static func loadSpot(by key: String, completion: @escaping((ParkingSpot?)->Void)) {
        let firRef = ref().child("parkingSpots").child(key)
        
        firRef.observeSingleEvent(of: .value) { (snapshot) in
            let spot = ParkingSpot(snapshot: snapshot)
            
            completion(spot)
        }
    }
    static func loadSpots(for userID: String, completion:@escaping(([ParkingSpot])->Void)) {
        let firRef = ref().child("parkingSpots").queryOrdered(byChild: "userID").queryEqual(toValue: userID)
        
        firRef.observeSingleEvent(of: .value) { (snapshot) in
            var spots:[ParkingSpot] = []
            
            if snapshot.exists() {
                let children = snapshot.children
                
                while let child = children.nextObject() as? DataSnapshot {
                    if let spot = ParkingSpot(snapshot: child) {
                        spots.append(spot)
                    }
                }
            }
            completion(spots)
        }
    }
    
    func update(location: CLLocation, completion:@escaping((Error?)->Void)) {
        let spotsRef = ref().child("parkingSpots")
        let geoFire = GeoFire(firebaseRef: spotsRef)
        geoFire.setLocation(location, forKey: self.key, withCompletionBlock: { (error) in
            completion(error)
        })
    }
    
    func delete(completion:@escaping((Error?)->Void)) {
        let firRef = ref().child("parkingSpots").child(self.key)
        
        firRef.removeValue { (error, ref) in
            completion(error)
        }
    }
    
    static func searchParkingSpots(near latitude: Double, longitude: Double, completion:@escaping(([ParkingSpot])->Void)) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let firRef = ref().child("parkingSpots")
        let geoFire = GeoFire(firebaseRef: firRef)
        
        
        let query = geoFire.query(at: location, withRadius: 1000)
        
        var spots:[ParkingSpot] = []
        
        let group = DispatchGroup()
        
        group.enter()
        let _ = query.observe(.keyEntered) { (key, location) in
            print("Entered:\(key) latitude:\(location.coordinate.latitude) longitude:\(location.coordinate.longitude)" )
            
            group.enter()
            ParkingSpot.loadSpot(by: key, completion: { (spot) in
                if let spot = spot {
                    spots.append(spot)
                }
                
                group.leave()
            })
            
        }
        group.leave()
        
        query.observeReady {
            print("ready")
            
            group.notify(queue: .main, execute: {
                completion(spots)
            })
        }
    }
    
}

enum BookType: String {
    case daily = "daily"
    case hourly = "hourly"
}
