//
//  SettingsViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import UIKit
import MessageUI
import Firebase

let appid = "12345678"


class SettingsViewController : UIViewController {
    
    @IBAction func onRateApp(_ sender: Any) {
        rateApp(appId: appid, completion: { (_) in
        })
    }
    @IBAction func onReportProblem(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            alertOk(title: "Mail", message: "Mail services are not available", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["Mrjorgecortez@gmail.com"])
        composeVC.setSubject("Report a bug")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            gotoViewController(id: "loginnvc", storyboardName: "Login")
        } catch {
            
        }
    }
    
    @IBAction func onPaymentInformation(_ sender: Any) {
        let vc = StripeViewController.newInst()
        vc.fromSetting = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
