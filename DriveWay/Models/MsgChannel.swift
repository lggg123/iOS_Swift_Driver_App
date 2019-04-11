//
//  MsgChannel.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import Foundation
import Firebase

internal class MsgChannel {
    var userID: String
    var time: Double
    var lastMsg: String
    var isRead: Bool
    
    init(userID: String, lastMsg: String, isRead: Bool) {
        self.userID = userID
        self.lastMsg = lastMsg
        self.time = Date().timeIntervalSince1970
        
        self.isRead = isRead
    }
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        let info = snapshot.value! as! NSDictionary
        
        guard let time = info[C.MsgChannel.time] as? Double,
            let lastMsg = info[C.MsgChannel.lastMsg] as? String
            else {
                return nil
        }
        
        self.userID = snapshot.key
        self.time = time
        self.lastMsg = lastMsg
        
        if let isRead = info[C.MsgChannel.isRead] as? Bool, isRead {
            self.isRead = true
        } else {
            self.isRead = false
        }
    }
    
    //    func save(completion:@escaping((Error?)->())) {
    //        let channelRef = ref().child(C.Root.messages).child(curid()!).child(self.userID)
    //
    //        var info:[String:Any] = [:]
    //        info[C.MsgChannel.lastMsg] = self.lastMsg
    //        info[C.MsgChannel.time] = ServerValue.timestamp()
    //
    //        channelRef.setValue(info) { (error, reference) in
    //            completion(error)
    //        }
    //    }
    
    func markRead() {
        let channelRef = ref().child(C.Root.messages).child(curid()!).child(self.userID)
        channelRef.child(C.MsgChannel.isRead).setValue(true)
    }
    
    func remove(completion:@escaping((Error?)->())) {
        let channelRef = ref().child(C.Root.messages).child(curid()!).child(self.userID)
        channelRef.removeValue { (error, reference) in
            completion(error)
        }
    }
    
    static func loadChannels(userID: String, completion:@escaping ([MsgChannel])->()) {
        var channels:[MsgChannel] = []
        
        let channelsRef = ref().child(C.Root.messages).child(userID)
        channelsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let children = snapshot.children
                
                while let child = children.nextObject() as? DataSnapshot {
                    if let channel = MsgChannel(snapshot: child) {
                        channels.append(channel)
                    }
                }
            }
            channels.sort(by: { (msg1, msg2) -> Bool in
                return msg1.time > msg2.time
            })
            completion(channels)
        })
    }
    
    static func loadChannel(userID: String, channelID: String, completion:@escaping (MsgChannel?)->()) {
        
        let channelRef = ref().child(C.Root.messages).child(userID).child(channelID)
        channelRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let channel = MsgChannel(snapshot: snapshot)
            completion(channel)
        })
    }
    
    static func createChannels(senderID: String, receiverID: String, completion:@escaping((Error?)->())) {
        let channel1 = C.Root.messages + "/" + senderID + "/" + receiverID + "/"
        let channel2 = C.Root.messages + "/" + receiverID + "/" + senderID + "/"
        
        var fanout : [String:Any] = [:]
        
        //update message channel
        fanout[channel1 + C.MsgChannel.lastMsg] = ""
        fanout[channel1 + C.MsgChannel.time] = ServerValue.timestamp()
        fanout[channel1 + C.MsgChannel.isRead] = true
        
        fanout[channel2 + C.MsgChannel.lastMsg] = ""
        fanout[channel2 + C.MsgChannel.time] = ServerValue.timestamp()
        fanout[channel2 + C.MsgChannel.isRead] = false
        
        ref().updateChildValues(fanout) { (error, reference) in
            completion(error)
        }
    }
    
}
