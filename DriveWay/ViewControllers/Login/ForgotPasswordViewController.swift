//
//  ForgotPasswordViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

import Firebase

class ForgotPasswordViewController : UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var imgValid: UIImageView!
    @IBOutlet weak var lblValid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfEmail.delegate = self
    }
    @IBAction func onSubmit(_ sender: Any) {
        
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
            if(exist) {
                
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        if error.localizedDescription.contains("no user record") {
                            self.alert(title: "Sign In", message: "This email does not exist in our records. Please try again or sign up to new account.", okButton: "Sign up", cancelButton: "Try again", okHandler: { (_) in
                                if let storyboard = self.storyboard {
                                    let vc = storyboard.instantiateViewController(withIdentifier: "signupvc") as! SignupViewController
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }, cancelHandler: nil)
                        } else {
                            self.alertOk(title: "Forgot Password", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                        }
                    } else {
                        self.alertOk(title: "Forgot Password", message: "Success! We’ve sent a password reset link to your email", cancelButton: "OK", cancelHandler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            } else {
                self.alert(title: "Sign In", message: "Email entered is not registered. Create an account now?", okButton: "Sign up", cancelButton: "Not now", okHandler: { (_) in
                    if let storyboard = self.storyboard {
                        let vc = storyboard.instantiateViewController(withIdentifier: "signupvc") as! SignupViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }, cancelHandler: nil)
            }
        }
        
    }
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let email = self.tfEmail.text!
        
        User.checkEmailExist(email: email) { (exist) in
            if(!exist) {
                self.imgValid.image = #imageLiteral(resourceName: "ic_input_invalid")
                self.lblValid.textColor = UIColor.lightGray
            } else {
                self.imgValid.image = #imageLiteral(resourceName: "ic_input_valid")
                self.lblValid.textColor = primaryColor
            }
        }
    }
}

