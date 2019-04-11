
//  ChatViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import ALCameraViewController

class ChatViewController : UIViewController {
    
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var table: UITableView!
    
    var thisChannel: MsgChannel!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var isLoaded = false
    var messages:[Message] = []
    
    //camera controller parameters
    var minimumSize: CGSize = CGSize(width: 60, height: 60)
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.separatorStyle = .none
        
//        //        automaticallyAdjustsScrollViewInsets = false

        if let userName = userNames[thisChannel.userID] {
            self.navigationItem.title = userName
        } else {
            self.navigationItem.title = ""
            User.loadUser(userID: thisChannel.userID, completion: { (user) in
                if let _ = user {
                    self.navigationItem.title = user!.displayName
                }
            })
        }

        setupSync()

        refresh()
    }
    
    static func newInst(channel: MsgChannel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chatvc") as! ChatViewController
        vc.thisChannel = channel
        return vc
    }
    
    @IBAction func onAttach(_ sender: Any) {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let image = image {
                self?.send(image: image)
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    @IBAction func onSend(_ sender: Any) {
        let msg = tfMessage.text!
        let trimmed = msg.trimmingCharacters(in: CharacterSet.whitespaces)
        
        
        if trimmed == "" || msg.length < 1 || msg.length > 1000 {
            alertOk(title: "Message", message: "Please enter message to send.", cancelButton: "OK", cancelHandler: nil)
        } else {
            self.view.endEditing(true)
            if let channel = thisChannel {
                if reachability.connection == .none {
                    self.alertOk(title: "No Internet Connection", message: "Please connect to the internet and try again.", cancelButton: "OK", cancelHandler: nil)
                    return
                }
                
                SVProgressHUD.show()
                Message.newMessage(opponentID: channel.userID, userID: curid()!, text: trimmed, image: nil, completion: { (error, message) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        if let error = error {
                            self.alertOk(title: "Message", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                        } else {
                            if let _ = message {
                                //                                self.messages.append(message)
                                //                                self.refresh()
                                
                                
                            }
                        }
                        
                    }
                })
            }
            
            tfMessage.text = ""
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        let time = animated ? 300 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(time)) {
            
            if self.table.contentSize.height > self.table.frame.size.height {
                let bottomOffset = CGPoint(x: 0, y: self.table.contentSize.height - self.table.frame.size.height)
                self.table.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func setupSync() {
        if let channel = thisChannel {
            channel.markRead()
            let msgRef = ref().child(C.Root.messages).child(curid()!).child(channel.userID).child(C.MsgChannel.messages)
            msgRef.observe(.childAdded, with: { (snapshot) in
                if let msg = Message(snapshot: snapshot) {
                    var isExist = false
                    for aMsg in self.messages {
                        if aMsg.key == msg.key {
                            isExist = true
                        }
                    }

                    if !isExist {
                        DispatchQueue.main.async {
                            self.messages.append(msg)
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.table.insertRows(at: [indexPath], with: .automatic)

                            self.tableViewScrollToBottom(animated: true)
                        }
                    }
                }
            })

            msgRef.observe(.childRemoved, with: { (snapshot) in
                if snapshot.exists() {
                    let key = snapshot.key
                    for i in 0..<self.messages.count {
                        let aMsg = self.messages[i]
                        if aMsg.key == key {
                            let indexPath = IndexPath(row: i, section: 0)
                            DispatchQueue.main.async {
                                self.table.reloadRows(at: [indexPath], with: .automatic)
                            }

                            break
                        }
                    }
                }
            })
        }
    }
    
    func refresh() {
        self.table.reloadData()
        refreshControl.endRefreshing()
        isLoaded = true
    }
    
    func send(image: UIImage) {
        if reachability.connection == .none {
            self.alertOk(title: "No Internet Connection", message: "Please connect to the internet and try again.", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        let path = curid()! + "/" + timestamp() + ".png"
        
        SVProgressHUD.show()
        //        let resized = image.resized(toWidth: 200, toHeight: 200)
        uploadImageTo(path: path, image: image, completionHandler: { (downloadURL, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Uploading Image", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                return
            }
            
            if let url = downloadURL {
                
                Message.newMessage(opponentID: self.thisChannel.userID, userID: curid()!, text: "", image: url, completion: { (error, message) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        if let error = error {
                            self.alertOk(title: "Message", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                        } else {
                            //                            if let message = message {
                            
                            //                            }
                        }
                        
                    }
                })
            }
        })
    }
}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let message = messages[row]
        let identifier = message.isMine ? "chatrighttc" : "chatlefttc"        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatCell
        cell.selectionStyle = .none
        cell.setData(message: message)
        return cell
    }
}

