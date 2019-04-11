//
//  CustomTabBarController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController : UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        
        if thisUser?.type == .customer {
            let customerHome = self.storyboard!.instantiateViewController(withIdentifier: "customerhomenvc")
            let customerBookings = self.storyboard!.instantiateViewController(withIdentifier: "customerbookingsnvc")
            //let home = self.storyboard!.instantiateViewController(withIdentifier: "usernvc")
            let messages = self.storyboard!.instantiateViewController(withIdentifier: "messagesnvc")
            let settings = self.storyboard!.instantiateViewController(withIdentifier: "settingsnvc")
            
            self.viewControllers = [customerHome, customerBookings, messages, settings]
        } else {
            let hostHome = self.storyboard!.instantiateViewController(withIdentifier: "hosthomenvc")
            let hostBookings = self.storyboard!.instantiateViewController(withIdentifier: "hostbookingsnvc")
            let messages = self.storyboard!.instantiateViewController(withIdentifier: "messagesnvc")
            let settings = self.storyboard!.instantiateViewController(withIdentifier: "settingsnvc")
            
            self.viewControllers = [hostHome, hostBookings, messages, settings]
        }
    }
}

