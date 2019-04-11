//
//  Global.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import Reachability

let reachability = Reachability(hostname: "www.google.com")!
let primaryColor = UIColor(hex: "0A334C")
let googlePlaceServerAPIKey = "AIzaSyBi1B8nj-Cl8NWeGny5rt0oJFL9WEd1GOA"
let API_URL_BASE = "http://stripe.riseofideas.com/public/driveway/"

let stripePublishableKey = "pk_test_q0CTvOMgt89fi7geI18PreqM"

var thisUser : User?

var userImages: [String:String] = [:]
var userNames: [String:String] = [:]
var userRatings: [String:Double] = [:]

enum MyError : Error {
    case uploadImage(reason: String)
    case downloadURL(reason: String)
    case parseComment(reason: String)
    case parseMessage(reason: String)
    case invalidUser(reason: String)
}


struct C {
    struct Root {
        static let users = "users"
        static let livestocks = "livestocks"
        static let messages = "messages"
        static let notifications = "notifications"
        static let livestockReports = "livestockReports"
        static let userReports = "userReports"
    }
    
    struct MsgChannel {
        static let lastMsg = "lastMsg"
        static let time = "time"
        static let messages = "messages"
        static let isRead = "isRead"
    }
    
    struct Messages {
        static let userID = "userID"
        static let text = "text"
        static let image = "image"
        static let time = "time"
        static let isRead = "isRead"
    }
}

var times: [String] = ["12 AM",
                       "01 AM",
                       "02 AM",
                       "03 AM",
                       "04 AM",
                       "05 AM",
                       "06 AM",
                       "07 AM",
                       "08 AM",
                       "09 AM",
                       "10 AM",
                       "11 AM",
                       "12 PM",
                       "01 PM",
                       "02 PM",
                       "03 PM",
                       "04 PM",
                       "05 PM",
                       "06 PM",
                       "07 PM",
                       "08 PM",
                       "09 PM",
                       "10 PM",
                       "11 PM",
                       "12 AM"
]
