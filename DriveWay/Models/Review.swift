//
//  Review.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import Firebase

struct Reviews {
    static let reviewID = "reviewID"
    static let rating = "rating"
    static let spotID = "spotID"
    static let contractID = "contractID"
    static let reviewerID = "reviewerID"
    static let content = "content"
    static let time = "time"
}
class Review {
    var reviewID: String
    var reviewerID: String
    var spotID: String
    var contractID: String
    var rating: Double
    var content: String //job title
    var time: TimeInterval
    
    init?(snapshot: DataSnapshot) {
        if(!snapshot.exists()) {
            return nil
        }
        
        let info = snapshot.value! as! NSDictionary
        
        self.reviewID = snapshot.key
        
        guard
            let rating = info[Reviews.rating] as? Double,
            let spotID = info[Reviews.spotID] as? String,
            let reviewerID = info[Reviews.reviewerID] as? String,
            let contractID = info[Reviews.contractID] as? String,
            let time = info[Reviews.time] as? TimeInterval,
            let content = info[Reviews.content] as? String else {
                return nil
        }
        self.rating = rating
        self.spotID = spotID
        self.contractID = contractID
        self.reviewerID = reviewerID
        self.content = content
        self.time = time
    }
    
    static func loadReview(reviewID: String, userID: String, completion:@escaping((Review?)->())) {
        let reviewPath = "\(C.Root.users)/\(userID)/\(Users.reviews)/\(reviewID)"
        let reviewRef =
            ref().child(reviewPath)
        reviewRef.observeSingleEvent(of: .value) { (snapshot) in
            if let review = Review(snapshot: snapshot) {
                completion(review)
            } else {
                completion(nil)
            }
        }
    }
    
    static func makeReview(rating: Double, spotID: String, contractID: String, content: String, completion:@escaping((Error?, String?)->())) {
        let reviewPath = "parkingSpots/\(spotID)/reviews"
        let reviewRef =
            ref().child(reviewPath).childByAutoId()
        let key = reviewRef.key
        
        var dic:[String:Any] = [:]
        
        dic[Reviews.reviewID] = key
        dic[Reviews.rating] = rating
        dic[Reviews.contractID] = contractID
        dic[Reviews.spotID] = spotID
        dic[Reviews.reviewerID] = thisUser!.userID
        dic[Reviews.content] = content
        dic[Reviews.time] = ServerValue.timestamp()
        
        
        reviewRef.updateChildValues(dic, withCompletionBlock: { (error, ref) in
            if let error = error {
                completion(error, nil)
            } else {
                completion(nil, key)
            }
        })
    }
    
    static func loadReviews(for spotID: String, completion:@escaping ([Review])->()) {
        var reviews:[Review] = []
        
        let reviewsRef = ref().child("parkingSpots").child(spotID).child("reviews")
        reviewsRef
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let children = snapshot.children
                    
                    while let child = children.nextObject() as? DataSnapshot {
                        if let review = Review(snapshot: child){
                            reviews.append(review)
                        }
                    }
                }
                completion(reviews)
            })
    }
}

