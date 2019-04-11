//
//  ParkingDetailViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Cosmos
import SVProgressHUD

class ParkingDetailViewController : UIViewController {
    
    @IBOutlet weak var viImage: UIView!
    @IBOutlet weak var viReport: UIView!
    @IBOutlet weak var svContent: UIScrollView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var cosRateView: CosmosView!
    @IBOutlet weak var lblReviews: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    
    @IBOutlet weak var lblPricing: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblCancelPolicy: UILabel!
    
    @IBOutlet weak var svButtons: UIStackView!
    
    var spot: ParkingSpot!
    var bookQuery: BookQuery?
    
    var imageViews:[UIImageView] = []
    
    var currentPage: Int = 0
    var numOfPages: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = self.view.frame.width
        let h = viImage.frame.size.height
        
        var i: Int = 0
        
        viImage.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        viImage.clipsToBounds = true
        for url in spot.photosURLs {
            let imageView = UIImageView(frame: CGRect(x: w * CGFloat(i), y: 0, width: w + 1, height: h))
            
            imageView.sd_setImage(with: URL(string: url), completed: nil)
            imageView.contentMode = .scaleAspectFill
            
            i += 1
            
            imageViews.append(imageView)
            viImage.addSubview(imageView)
        }
        
        numOfPages = spot.photosURLs.count
        pageCtrl.numberOfPages = numOfPages
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(self.swipePage))
        swipeRightRecognizer.direction = .right
        self.viImage.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(self.swipePage))
        swipeLeftRecognizer.direction = .left
        self.viImage.addGestureRecognizer(swipeLeftRecognizer)
        
        lblName.text = spot.title
        lblUserName.setNameFor(userID: spot.userID, prefix: "")
        cosRateView.rating = spot.rating
        lblReviews.text = "\(spot.reviews.count) reviews"
        
        lblLocation.text = spot.address
        lblAbout.text = spot.about
        lblTerms.text = spot.terms
        lblCancelPolicy.text = spot.cancelPolicy
        
        if spot.bookType == .hourly {
            lblPricing.text = "1 Hour Parking at $\(spot.pricePerHour)"
        } else {
            lblPricing.text = "24 Hours Parking at $\(spot.pricePerDay)"
        }
        
        if spot.userID == thisUser?.userID {
            svButtons.isHidden = true
        }
        
        let tapUserName = UITapGestureRecognizer(target: self, action: #selector(self.onUserName))
        lblUserName.isUserInteractionEnabled = true
        lblUserName.addGestureRecognizer(tapUserName)
        
        let tapReview = UITapGestureRecognizer(target: self, action: #selector(self.onReviews))
        lblReviews.isUserInteractionEnabled = true
        lblReviews.addGestureRecognizer(tapReview)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        svContent.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    @objc func onUserName() {
        User.loadUser(userID: self.spot.userID) { (user) in
            if let user = user {
                let vc = ProfileViewController.newInst(user: user)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }        
    }
    
    @objc func onReviews() {
        let vc = RatingsViewController.newInst(spot: self.spot)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func swipePage(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if(pageCtrl.currentPage > 0) {
                    pageCtrl.currentPage -= 1
                    
                    let delta = CGFloat(pageCtrl.currentPage - self.currentPage)
                    movePage(delta: delta)
                } else {
                    
                }
                
                
                break
                
            case UISwipeGestureRecognizerDirection.left:
                if(pageCtrl.currentPage < numOfPages-1) {
                    pageCtrl.currentPage += 1
                    
                    let delta = CGFloat(pageCtrl.currentPage - self.currentPage)
                    movePage(delta: delta)
                } else {
                    
                }
                
                break
            default:
                break;
            }
            
            
        }
    }
    
    func movePage(delta: CGFloat) {
        let width = self.viImage.frame.size.width
        
        UIView.animate(withDuration: 0.5, animations: {
            for imageView in self.imageViews {
                imageView.frame = imageView.frame.offsetBy(dx: -width * delta, dy: 0)
            }
            
        }) { (ret) in
            
        }
        self.currentPage = pageCtrl.currentPage
    }
    
    @IBAction func onMessageToHost(_ sender: Any) {
        SVProgressHUD.show()
        gotoChatRoom(userID: spot.userID)
    }
    @IBAction func onReport(_ sender: Any) {
        viReport.isHidden = false
    }
    @IBAction func onDoReport(_ sender: Any) {
        viReport.isHidden = true
    }
    @IBAction func onDoCancel(_ sender: Any) {
        viReport.isHidden = true
    }
    @IBAction func onPageChanged(_ sender: Any) {
        let changedPage = pageCtrl.currentPage
        let delta = CGFloat(changedPage - self.currentPage)
        
        movePage(delta: delta)
    }
    
    @IBAction func onBookNow(_ sender: Any) {
        if let query = self.bookQuery {
            let vc = BookingDetailViewController.newInst(spot: self.spot, bookQuery: query)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    static func newInst(spot: ParkingSpot, bookQuery: BookQuery? = nil) -> UIViewController {
        let vc = UIStoryboard(name: "CustomerHome", bundle: nil).instantiateViewController(withIdentifier: "parkingdetailvc") as! ParkingDetailViewController
        
        vc.spot = spot
        vc.bookQuery = bookQuery
        
        return vc        
    }
}
