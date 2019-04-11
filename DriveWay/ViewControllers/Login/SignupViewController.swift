//
//  SignupViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class SignupViewController : UIViewController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var imgValid: UIImageView!
    @IBOutlet weak var imgNotInUse: UIImageView!
    @IBOutlet weak var lblValid: UILabel!
    @IBOutlet weak var lblNotInUse: UILabel!
    
    @IBAction func onNext(_ sender: Any) {
        if reachability.connection == .none {
            alertOk(title: "No internet connection", message: "Please connect to the internet and try again", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        self.view.endEditing(true)
        
        let email = self.tfEmail.text!
        let trimmed = email.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if trimmed == "" {
            alertOk(title: "Sign Up", message: "Please enter email address", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        if !isEmailValid(email: email) {
            return
        }
        
        User.checkEmailExist(email: email) { (exist) in
            if(!exist) {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "signup2vc") as! Signup2ViewController
                
                vc.email = email
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.delegate = self
    }
}

extension SignupViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let email = self.tfEmail.text!
        
        if isEmailValid(email: email) {
            imgValid.image = #imageLiteral(resourceName: "ic_input_valid")
            lblValid.textColor = primaryColor
        } else {
            imgValid.image = #imageLiteral(resourceName: "ic_input_invalid")
            lblValid.textColor = UIColor.lightGray
        }
        
        User.checkEmailExist(email: email) { (exist) in
            if(exist) {
                self.imgNotInUse.image = #imageLiteral(resourceName: "ic_input_invalid")
                self.lblNotInUse.textColor = UIColor.lightGray
            } else {
                self.imgNotInUse.image = #imageLiteral(resourceName: "ic_input_valid")
                self.lblNotInUse.textColor = primaryColor
            }
        }
    }
}

