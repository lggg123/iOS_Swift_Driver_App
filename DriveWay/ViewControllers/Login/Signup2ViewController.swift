//
//  Signup1ViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class Signup2ViewController : UIViewController {
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var img6Chars: UIImageView!
    @IBOutlet weak var imgNumber: UIImageView!
    @IBOutlet weak var imgUppercase: UIImageView!
    @IBOutlet weak var imgLowercase: UIImageView!
    
    @IBOutlet weak var lblUppercase: UILabel!
    @IBOutlet weak var lblLowercase: UILabel!
    @IBOutlet weak var lbl6Chars: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfPassword.delegate = self
    }
    
    @IBAction func onNext(_ sender: Any) {
        self.view.endEditing(true)
        
        let passwd = self.tfPassword.text!
        
        if passwd.length > 20 {
            alertOk(title: "Sign Up", message: "Password length should be less than 20 characters", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        if passwd.length >= 6, passwd.length <= 20,
            passwd.containsUppercase, passwd.containsLowercase,
            passwd.containsNumber,
            passwd.containsLetter {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "signup3vc") as! Signup3ViewController
            vc.email = self.email
            vc.password = passwd
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Signup2ViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let passwd = self.tfPassword.text!
        
        if passwd.length >= 6 {
            img6Chars.image = #imageLiteral(resourceName: "ic_input_valid")
            lbl6Chars.textColor = primaryColor
        } else {
            img6Chars.image = #imageLiteral(resourceName: "ic_input_invalid")
            lbl6Chars.textColor = UIColor.lightGray
        }
        
        if passwd.containsNumber {
            imgNumber.image = #imageLiteral(resourceName: "ic_input_valid")
            lblNumber.textColor = primaryColor
        } else {
            imgNumber.image = #imageLiteral(resourceName: "ic_input_invalid")
            lblNumber.textColor = UIColor.lightGray
        }
        
        if passwd.containsUppercase {
            imgUppercase.image = #imageLiteral(resourceName: "ic_input_valid")
            lblUppercase.textColor = primaryColor
        } else {
            imgUppercase.image = #imageLiteral(resourceName: "ic_input_invalid")
            lblUppercase.textColor = UIColor.lightGray
        }
        
        if passwd.containsLowercase {
            imgLowercase.image = #imageLiteral(resourceName: "ic_input_valid")
            lblLowercase.textColor = primaryColor
        } else {
            imgLowercase.image = #imageLiteral(resourceName: "ic_input_invalid")
            lblLowercase.textColor = UIColor.lightGray
        }
        
    }
}

