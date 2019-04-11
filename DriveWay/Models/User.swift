//
//  User.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

enum UserType : String {
    case customer = "customer"
    case host = "host"
    case admin = "admin"
}

struct Users {
    static let userID = "userID"
    static let type = "type"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let email = "email"
    static let about = "about"
    
    static let banned = "banned"
    
    //optional fields
    static let photoURL = "photoUrl"
    
    
    static let reviews = "reviews"
    static let deviceToken = "deviceToken"
    
    static let stripeCustomerID = "stripeCustomerId"
    static let stripeAccountID = "stripeAccountId"
    
    static let createdAt = "createdAt"
}

class User {
    
    let userID: String
    let type: UserType
    let email: String
    
    let firstName: String?
    let lastName: String?
    let about: String?
    
    
    var photoURL: String?
    var banned: Bool
    
    //generated variable
    var displayName: String
    var isMe: Bool
    
    var rating: Double
    
    //runtime variables
    var location: CLLocation? = nil
    var subscribed: Bool? = nil
    var expiryDate: Date?
    
    var stripeAccountID: String?
    var stripeCustomerID: String?
    
    var createdAt: TimeInterval?
    
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        let info = snapshot.value! as! NSDictionary
        
        self.userID = snapshot.key
        
        if let loggedUserId = curid(), loggedUserId == self.userID {
            self.isMe = true
        } else {
            self.isMe = false
        }
        
        guard let email = info[Users.email] as? String,
            let stype = info[Users.type] as? String, let type = UserType(rawValue: stype)
            else {
                return nil
        }
        self.type = type
        self.email = email
        
        if type == .admin {
            firstName = ""
            lastName = ""
            displayName = ""
            
            about = nil
            photoURL = nil
            banned = false
            rating = 0
            createdAt = nil
            
        } else {
            
            guard let firstName = info[Users.firstName] as? String,
                let lastName = info[Users.lastName] as? String else {
                    return nil
            }
            
            self.firstName = firstName
            self.lastName = lastName
            self.about = info[Users.about] as? String
            
            self.createdAt = info[Users.createdAt] as? TimeInterval
            
            displayName = firstName + " " + lastName
            photoURL = info[Users.photoURL] as? String
            
            self.stripeAccountID = info[Users.stripeAccountID] as? String
            self.stripeCustomerID = info[Users.stripeCustomerID] as? String
            
            if let banned = info[Users.banned] as? Bool {
                self.banned = banned
            } else {
                self.banned = false
            }
            
            var sum: Double = 0
            var ratingCount: Int = 0
            if let reviews:[String:Any] = info[Users.reviews] as? [String:Any] {
                
                for reviewKey in reviews.keys {
                    if let review = reviews[reviewKey] as? [String:Any],
                        
                        let r =  review[Reviews.rating] as? Double {
                        sum += r
                        ratingCount += 1
                    }
                }
                
                self.rating = ratingCount > 0 ? sum / Double(ratingCount) : 0
            } else {
                self.rating = 0
            }
        }
    }
    
    func update(field: String, value: Any) {
        let userRef = ref().child(C.Root.users).child(self.userID)
        userRef.child(field).setValue(value)
    }
    
    func ban() {
        self.banned = true
        update(field: Users.banned, value: true)
    }
    
    func unban() {
        self.banned = false
        update(field: Users.banned, value: false)
    }
    
    func deleteUser() {
        let userRef = ref().child(C.Root.users).child(self.userID)
        userRef.removeValue()
    }
    
    
    static func loadUser(userID: String, completion: @escaping((User?)->())) {
        let userRef = ref().child(C.Root.users).child(userID)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            completion(user)
        })
    }
    static func loadUsers(completion:@escaping ([User])->()) {
        var users:[User] = []
        
        let usersRef = ref().child(C.Root.users)
        usersRef
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let children = snapshot.children
                    
                    while let child = children.nextObject() as? DataSnapshot {
                        if let user = User(snapshot: child){
                            users.append(user)
                        }
                    }
                }
                completion(users)
            })
    }
    
    
    static func checkEmailExist(email: String, completion: @escaping (_ isValid: Bool) -> Void) {
        ref().child(C.Root.users).queryOrdered(byChild: Users.email).queryEqual(toValue: "\(email)")
            .observeSingleEvent(of: .value, with: { snapshot in
                
                if ( !snapshot.exists() || snapshot.value is NSNull ) {
                    completion(false)
                    
                } else {
                    completion(true)
                }
            })
    }
    
    static func currentLoggedUser(completion:@escaping((User?)->())) {
        if let userid = curid() {
            ref().child(C.Root.users).child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        } else {
            completion(nil)
        }
    }
    
}

