//
//  ProfileViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class ProfileViewController : UIViewController {
    var theUser: User?
    
    var sizeForHeader = CGSize(width: 320, height: 100)
    
    var spots: [ParkingSpot] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func load() {
        guard let userID = self.theUser?.userID else { return }
        ParkingSpot.loadSpots(for: userID) { (spots) in
            self.spots = spots
        }
    }
    
    static func newInst(user: User?) -> UIViewController {
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "profilevc") as! ProfileViewController
        vc.theUser = user
        
        return vc
    }
    
    @IBOutlet weak var viReportContainer: UIView!
    @IBOutlet weak var tvReport: KMPlaceholderTextView!
    
    @IBAction func onShowReport(_ sender: Any) {
        viReportContainer.isHidden = false
        tvReport.text = ""
    }
    @IBAction func onReport(_ sender: Any) {
        let content = tvReport.text!
        
        if content.length < 3 {
            self.alertOk(title: "Error", message: "Please input more than 3 characters", cancelButton: "OK", cancelHandler: nil)
        }
        
        guard let user = self.theUser else { return }
        UserReport.makeUserReport(userID: user.userID, reason: content) { (error, _) in
            if let error = error {
                self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
            } else {
                self.viReportContainer.isHidden = true
            }
        }
    }
    @IBAction func onCancel(_ sender: Any) {
        viReportContainer.isHidden = true
    }
    
}


extension ProfileViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spottc", for: indexPath) as! ParkingSpotCollectionCell
        cell.setData(spot: self.spots[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let spot = self.spots[indexPath.row]
        
        let vc = ParkingDetailViewController.newInst(spot: spot)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profileheaderview", for: indexPath) as! ProfileHeaderView
        if let user = self.theUser {
            headerView.setData(user: user, spotsCount: self.spots.count)
        }
    
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        
        sizeForHeader = frame.size
        print("***** setting sizeForHeader \(sizeForHeader.width),\(sizeForHeader.height)")
            return headerView
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("***** using sizeForHeader \(sizeForHeader.width),\(sizeForHeader.height)")
        return sizeForHeader
    }
}
