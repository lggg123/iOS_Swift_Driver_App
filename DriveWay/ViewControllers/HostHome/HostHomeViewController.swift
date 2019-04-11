//
//  HostHomeViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class HostHomeViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var spots:[ParkingSpot] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageTitle()
        
        let nib = UINib(nibName: "ParkingSlotCollectionCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "parkingslotcc")
        
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        guard let userID = thisUser?.userID else { return }
        
        ParkingSpot.loadSpots(for: userID) { (spots) in
            self.spots = spots
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hosthomecc", for: indexPath) as! HostHomeCollectionCell
        
        let spot = self.spots[indexPath.row]
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setData(spot: spot)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let spot = self.spots[indexPath.row]
        
        let vc = ParkingDetailViewController.newInst(spot: spot)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2 - 8
        let height = width
        
        return CGSize(width: width, height: height)
    }

    @IBAction func onAdd(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ParkingSpot", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "parkingspotnvc")
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension HostHomeViewController : HostHomeCollectionCellDelegate {
    func onOption(indexPath: IndexPath) {
        let spot = self.spots[indexPath.row]
        
        let alerts = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alerts.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
            let vc = AddParkingTimeViewController.newInst(spot: spot)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        alerts.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            spot.delete(completion: { (error) in
                if let error = error {
                    self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    return
                } else {
                    self.spots.remove(at: indexPath.row)
                }
            })
        }))
        
        alerts.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            
        }))
        
        alerts.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alerts, animated: true, completion: nil)
    }
}
