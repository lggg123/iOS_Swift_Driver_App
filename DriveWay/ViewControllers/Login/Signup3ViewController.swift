//
//  Signup3ViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class Signup3ViewController : UIViewController {
    var email: String!
    var password: String!
    
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var imgConfirmPassword: UIImageView!
    @IBOutlet weak var lblConfirmPassword: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfConfirmPassword.delegate = self
    }
    
    @IBAction func onNext(_ sender: Any) {
        let confirmPasswd = tfConfirmPassword.text!
        
        if self.password == confirmPasswd {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "signup4vc") as! Signup4ViewController
            vc.email = self.email
            vc.password = self.password
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Signup3ViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let confirmPasswd = tfConfirmPassword.text!
        
        if self.password == confirmPasswd {
            imgConfirmPassword.image = #imageLiteral(resourceName: "ic_input_valid")
            lblConfirmPassword.textColor = primaryColor
        } else {
            imgConfirmPassword.image = #imageLiteral(resourceName: "ic_input_invalid")
            lblConfirmPassword.textColor = UIColor.lightGray
        }
    }
}

