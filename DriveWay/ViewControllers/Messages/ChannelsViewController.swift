//
//  ChannelsViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import Reachability


class ChannelsViewController : UITableViewController {

    var channels:[MsgChannel] = []
    var isMessagesLoaded = false
    var channelRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageTitle()
        
        self.tableView.separatorStyle = .none
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let notifName = Notification.Name("message")
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: notifName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh),name: Notification.Name.reachabilityChanged ,object: reachability)
        
        setupSync()
        
        refresh()

    }
    
    func setupSync() {
        self.channelRef = ref().child(C.Root.messages).child(curid()!)
        
        channelRef!.observe(.childAdded, with: { (snapshot) in
            if self.isMessagesLoaded, let channel = MsgChannel(snapshot: snapshot) {
                DispatchQueue.main.async {
                    self.channels.insert(channel, at: 0)
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        })
        
        channelRef!.observe(.childRemoved, with: { (snapshot) in
            if self.isMessagesLoaded,  let channel = MsgChannel(snapshot: snapshot) {
                DispatchQueue.main.async {
                    for i  in 0..<self.channels.count {
                        let aChannel = self.channels[i]
                        
                        if aChannel.userID == channel.userID {
                            self.channels.remove(at: i)
                            self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                            break
                        }
                    }
                    
                }
            }
        })
        
        channelRef!.observe(.childChanged, with: { (snapshot) in
            if self.isMessagesLoaded, let channel = MsgChannel(snapshot: snapshot) {
                DispatchQueue.main.async {
                    for i  in 0..<self.channels.count {
                        let aChannel = self.channels[i]
                        
                        if aChannel.userID == channel.userID {
                            self.channels.remove(at: i)
                            self.channels.insert(channel, at: 0)
                            
                            self.tableView.reloadData()
                            break
                        }
                    }
                    
                }
            }
        })
    }
    
    deinit {
        channelRef?.removeAllObservers()
    }

    @objc func refresh() {
        if reachability.connection != .none {
            if let userid = curid() {
                MsgChannel.loadChannels(userID: userid) { (channels) in
                    self.channels.removeAll()
                    self.channels = channels
                    
                    DispatchQueue.main.async {
                        self.isMessagesLoaded = true
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
            
            
        } else {
            channels.removeAll()
            isMessagesLoaded = true
            tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channeltc", for: indexPath) as! ChannelTableCell

        let row = indexPath.row
        let channel = channels[row]
        
        cell.selectionStyle = .none
        cell.avatarDelegate = self
        cell.setChannel(channel: channel)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = self.channels[indexPath.row]
        
        let vc = ChatViewController.newInst(channel: channel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row
            let channel = channels[row]
            
            alert(title: "Delete", message: "Are you sure you want to delete this message?", okButton: "Delete", cancelButton: "No", okHandler: { (_) in
                channel.remove(completion: { (error) in
                    if let _ = error {
                        self.alertOk(title: "Delete", message: "Can not remove this message. Please try agin later.", cancelButton: "OK", cancelHandler: nil)
                    } else {
                        
                    }
                    
                })
            }, cancelHandler: nil)
        }
    }
}
