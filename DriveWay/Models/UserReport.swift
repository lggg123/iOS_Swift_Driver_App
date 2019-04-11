//
//  UserReport.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import Firebase

struct UserReports {
    static let userReportID = "userReportID"
    static let reporterID = "reporterID"
    static let reason = "reason"
    static let time = "time"
}

internal class UserReport {
    let userReportID: String
    let userID: String
    let reporterID: String
    let reason: String
    let time: TimeInterval
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        let info = snapshot.value! as! NSDictionary
        
        self.userReportID = snapshot.key
        
        guard
            let userID = info[Users.userID] as? String,
            let reporterID = info[UserReports.reporterID] as? String,
            let reason = info[UserReports.reason] as? String,
            let time = info[UserReports.time] as? TimeInterval
            else {
                return nil
        }
        
        self.userID = userID
        self.reporterID = reporterID
        self.reason = reason
        self.time = time
    }
    func reportRef() -> DatabaseReference {
        return ref().child(C.Root.userReports).child(self.userReportID)
    }
    
    func deleteThisReport() {
        reportRef().removeValue();
    }
    
    
    static func makeUserReport(userID: String, reason: String, completion:@escaping((Error?, String?)->())) {
        let reportRef =
            ref().child(C.Root.userReports).childByAutoId()
        let key = reportRef.key
        
        var dic:[String:Any] = [:]
        dic[UserReports.userReportID] = key
        dic[Users.userID ] = userID
        dic[UserReports.reporterID] = thisUser!.userID
        dic[UserReports.reason] = reason
        dic[UserReports.time] = ServerValue.timestamp()
        
        reportRef.setValue(dic) { (error, reference) in
            if let error = error {
                completion(error, nil)
            } else {
                completion(nil, key)
            }
        }
    }
    static func loadUserReports(completion:@escaping ([UserReport])->()) {
        var reports:[UserReport] = []
        
        let reportsRef = ref().child(C.Root.userReports)
        reportsRef
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let children = snapshot.children
                    
                    while let child = children.nextObject() as? DataSnapshot {
                        if let report = UserReport(snapshot: child){
                            reports.append(report)
                        }
                    }
                }
                completion(reports)
            })
    }
    
}

