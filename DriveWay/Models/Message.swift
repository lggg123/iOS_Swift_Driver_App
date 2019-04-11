//
//  Message.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import Foundation
import Firebase

internal class Message {
    var key: String
    var userID: String
    var text: String
    var image: String?
    var time: Double
    //    var isRead: Bool
    
    var isMine: Bool
    
    init?(snapshot: DataSnapshot) {
        if !snapshot.exists() {
            return nil
        }
        
        let info = snapshot.value! as! NSDictionary
        
        guard let text = info[C.Messages.text] as? String,
            let time = info[C.Messages.time] as? Double,
            let userID = info[C.Messages.userID] as? String
            else {
                return nil
        }
        
        self.key = snapshot.key
        self.userID = userID
        self.text = text
        self.time = time
        
        if let url = info[C.Messages.image] as? String {
            self.image = url
        } else {
            self.image = nil
        }
        
        if let myID = curid(), userID == myID {
            self.isMine = true
        } else {
            self.isMine = false
        }
    }
    
    init?(key: String, info:[String:Any]) {
        guard let text = info[C.Messages.text] as? String,
            let time = info[C.Messages.time] as? Double,
            let userID = info[C.Messages.userID] as? String
            else {
                return nil
        }
        self.key = key
        self.text = text
        self.time = time
        self.userID = userID
        
        if let url = info[C.Messages.image] as? String {
            self.image = url
        }
        
        if let myID = curid(), userID == myID {
            self.isMine = true
        } else {
            self.isMine = false
        }
    }
    
    static func loadMessages(userID: String, channelID: String, completion:@escaping ([Message])->()) {
        var messages:[Message] = []
        
        let messagesRef = ref().child(C.Root.messages).child(userID).child(channelID)
        messagesRef
            .queryOrdered(byChild: C.Messages.time)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let children = snapshot.children
                    
                    while let child = children.nextObject() as? DataSnapshot {
                        if let message = Message(snapshot: child){
                            messages.append(message)
                        }
                    }
                }
                completion(messages)
            })
    }
    
    static func newMessage(opponentID: String, userID: String, text: String, image: String?, completion:@escaping((Error?, Message?)->())) {
        let messageRef = ref().child(C.Root.messages).child(curid()!).child(opponentID).child(C.MsgChannel.messages).childByAutoId()
        let msgKey = messageRef.key
        
        let channel1 = C.Root.messages + "/" + curid()! + "/" + opponentID + "/"
        let channel2 = C.Root.messages + "/" + opponentID + "/" + curid()! + "/"
        
        var fanout : [String:Any] = [:]
        
        //update message channel
        fanout[channel1 + C.MsgChannel.lastMsg] = text
        fanout[channel1 + C.MsgChannel.time] = ServerValue.timestamp()
        fanout[channel1 + C.MsgChannel.isRead] = true
        
        fanout[channel2 + C.MsgChannel.lastMsg] = text
        fanout[channel2 + C.MsgChannel.time] = ServerValue.timestamp()
        fanout[channel2 + C.MsgChannel.isRead] = false
        
        //add message
        let msg1 = channel1 + C.MsgChannel.messages + "/" + msgKey + "/"
        fanout[msg1 + C.Messages.userID] = userID
        fanout[msg1 + C.Messages.time] = ServerValue.timestamp()
        fanout[msg1 + C.Messages.text] = text
        fanout[msg1 + C.Messages.image] = image
        
        let msg2 = channel2 + C.MsgChannel.messages + "/" + msgKey + "/"
        fanout[msg2 + C.Messages.userID] = userID
        fanout[msg2 + C.Messages.time] = ServerValue.timestamp()
        fanout[msg2 + C.Messages.text] = text
        fanout[msg2 + C.Messages.image] = image
        
        
        ref().updateChildValues(fanout) { (error, reference) in
            if let error = error {
                completion(error, nil)
            } else {
                ref().child(msg1).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let msg = Message(snapshot: snapshot) {
                        completion(nil, msg)
                        
                        
                    } else {
                        completion(MyError.parseMessage(reason: "Can not parse message"), nil)
                    }
                })
            }
            
        }
    }
}
