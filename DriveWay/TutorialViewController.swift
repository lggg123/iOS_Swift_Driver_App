//
//  ViewController.swift
//  Driveway
//
//  Created by imac on 4/28/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class TutorialViewController : UIViewController {
    
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    var currentPage:Int = 0
    let numOfPages = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let w = view1.frame.size.width
        let h = view1.frame.size.height
        
        view2.frame = CGRect(x: w, y: 0, width: w+1, height: h)
        view3.frame = CGRect(x: w*2, y: 0, width: w+1, height: h)
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(self.swipePage))
        swipeRightRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(self.swipePage))
        swipeLeftRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeLeftRecognizer)
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
                    gotoViewController(id: "loginnvc", storyboardName: "Login")
                    UserDefaults.standard.set(true, forKey: "tutorial")
                }
                
                break
            default:
                break;
            }
            
            
        }
    }
    
    
    @IBAction func onPageChange(_ sender: Any) {
        let changedPage = pageCtrl.currentPage
        let delta = CGFloat(changedPage - self.currentPage)
        
        movePage(delta: delta)
    }
    
    func movePage(delta: CGFloat) {
        let width = self.view1.frame.size.width
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view1.frame = self.view1.frame.offsetBy(dx: -width * delta, dy: 0)
            self.view2.frame = self.view2.frame.offsetBy(dx: -width * delta, dy: 0)
            self.view3.frame = self.view3.frame.offsetBy(dx: -width * delta, dy: 0)
            
        }) { (ret) in
            
        }
        self.currentPage = pageCtrl.currentPage
        
        if self.currentPage == numOfPages-1 {
            // if last page
            btnNext.setTitle("All Done!", for: .normal)
            btnSkip.isHidden = true
        } else {
            btnNext.setTitle("Next", for: .normal)
            btnSkip.isHidden = false
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        if currentPage == numOfPages-1 {
            gotoViewController(id: "loginnvc", storyboardName: "Login")
            UserDefaults.standard.set(true, forKey: "tutorial")
        } else {
            pageCtrl.currentPage = currentPage + 1
            movePage(delta: 1)
        }
    }
    
    @IBAction func onSkip(_ sender: Any) {
        gotoViewController(id: "loginnvc", storyboardName: "Login")
        UserDefaults.standard.set(true, forKey: "tutorial")
    }
    
}
