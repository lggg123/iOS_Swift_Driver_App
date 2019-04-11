//
//  EditProfileViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ALCameraViewController


class EditProfileViewController : UIViewController {
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfOldPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var imgPhoto: UIImageView!

    @IBOutlet weak var viFirstName: UIView!
    @IBOutlet weak var viLastName: UIView!
    @IBOutlet weak var viEmail: UIView!
    @IBOutlet weak var viOldPassword: UIView!
    @IBOutlet weak var viNewPassword: UIView!
    @IBOutlet weak var viConfirmPassword: UIView!
    
    var avatarLoaded = false
    
    //camera controller parameters
    var minimumSize: CGSize = CGSize(width: 60, height: 60)
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.onUploadPhoto))
        imgPhoto.isUserInteractionEnabled = true
        imgPhoto.addGestureRecognizer(tapPhoto)
        
        if let user = thisUser {
            tfFirstName.text = user.firstName
            tfLastName.text = user.lastName
            tfEmail.text = user.email
            
            if let url = user.photoURL {
                imgPhoto.sd_setImage(with: URL(string: url)!, completed: nil)
            }
            
        }
    }
    
    @objc func onUploadPhoto() {
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let image = image {
                self?.imgPhoto.image = image
                self?.avatarLoaded = true
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    static func newInst() -> UIViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "editprofilevc")
        return vc
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        if reachability.connection == .none {
            alertOk(title: "No internet connection", message: "Please connect to the internet and try again", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        self.view.endEditing(true)
        
        SVProgressHUD.show()
        
        parse { (errors) in
            if errors > 1 {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Edit Profile", message: "We detected a few errors. Help me review your answers and try again.", cancelButton: "OK", cancelHandler: nil)
            } else if errors == 1 {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Edit Profile", message: "We detected an error. Help me review your answer and try again.", cancelButton: "OK", cancelHandler: nil)
            } else {
                
                let old = self.tfOldPassword.text!
                let passwd = self.tfNewPassword.text!
                let email = self.tfEmail.text!
                
                if old == "" && passwd == "" {
                    self.uploadImageAndSetupUserInfo()
                    return
                }
                
                let credential = EmailAuthProvider.credential(withEmail: thisUser!.email, password: old)
                Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                    if let error = error {
                        SVProgressHUD.dismiss()
                        self.alertOk(title: "Change Password", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    } else {
                        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                            if let error = error {
                                SVProgressHUD.dismiss()
                                self.alertOk(title: "Change Password", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                            } else {
                                Auth.auth().currentUser?.updatePassword(to: passwd, completion: { (error) in
                                    if let error = error {
                                        SVProgressHUD.dismiss()
                                        self.alertOk(title: "Change Password", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                                    } else {
                                        self.uploadImageAndSetupUserInfo()
                                    }
                                    
                                })
                            }
                        })
                        
                    }
                })
                
            }
        }
    }
    
    func uploadImageAndSetupUserInfo() {
        if avatarLoaded, let image = self.imgPhoto.image {
            let path = curid()! + "/" + timestamp() + ".png"
            
            
            let resized = image.resized(toWidth: 200, toHeight: 200)
            uploadImageTo(path: path, image: resized, completionHandler: { (downloadURL, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.alertOk(title: "Uploading Profile Image", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    return
                }
                
                if let url = downloadURL {
                    self.saveUserInfo(imageURL: url)
                    
                } else {
                    self.saveUserInfo(imageURL: nil)
                }
            })
        } else {
            self.saveUserInfo(imageURL: nil)
        }
    }
    
    func saveUserInfo(imageURL: String?) {
        // setup user information in db
        
        let firstName = tfFirstName.text!
        let lastName = tfLastName.text!
        
        
        var userData:[String:String] = [:]
        
        if let url = imageURL {
            userData[Users.photoURL] = url
        }
        userData[Users.type] = UserType.customer.rawValue
        userData[Users.firstName] = firstName
        userData[Users.lastName] = lastName
        userData[Users.photoURL] = imageURL
        userData[Users.userID] = curid()!
        
        ref().child(C.Root.users).child(curid()!).updateChildValues(userData, withCompletionBlock: { (error, ref) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Edit Profile", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                
                return
            } else {
                User.currentLoggedUser(completion: { (user) in
                    SVProgressHUD.dismiss()
                    if let user = user {
                        thisUser = user
                        
                        userNames[user.userID] = user.displayName
                        userImages[user.userID] = user.photoURL
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.alertOk(title: "Edit Profile", message: "Something wrong with your profile information. Please contact customer support.", cancelButton: "OK", cancelHandler: nil)
                    }
                })
                
            }
        })
    }
    
    
    func parse(completion:@escaping((Int)->())) {
        var errors = 0
        
        let _firstName = tfFirstName.text!
        let _lastName = tfLastName.text!
        
        var trimmed = _firstName.trimmingCharacters(in: .whitespaces)
        
        if trimmed == "" || _firstName.length < 3 || _firstName.length > 20 || !isNameValid(name: _firstName){
            errors += 1
            
            self.viFirstName.borderColor = UIColor.red
        } else {
            self.viFirstName.borderColor = .clear
            
        }
        
        trimmed = _lastName.trimmingCharacters(in: .whitespaces)
        
        if trimmed == "" || _lastName.length < 3 || _lastName.length > 20 || !isNameValid(name: _firstName){
            errors += 1
            
            self.viLastName.borderColor = UIColor.red
        } else {
            self.viLastName.borderColor = UIColor.clear
        }
        
        let email = self.tfEmail.text!
        trimmed = email.trimmingCharacters(in: CharacterSet.whitespaces)
        
        
        
        if trimmed == "" || !isEmailValid(email: email) {
            errors += 1
            self.viEmail.borderColor = UIColor.red
        } else {
            self.viEmail.borderColor = UIColor.clear
        }
        
        let passwd = self.tfNewPassword.text!
        
        if passwd != "" && tfOldPassword.text != "" {
            if passwd.length >= 6, passwd.length <= 20,
                passwd.containsUppercase, passwd.containsLowercase,
                passwd.containsNumber,
                passwd.containsLetter {
                self.viNewPassword.borderColor = UIColor.clear
            } else {
                errors += 1
                
                self.viNewPassword.borderColor = UIColor.red
            }
            
            let confirmPasswd = tfConfirmPassword.text!
            if passwd == confirmPasswd {
                self.viConfirmPassword.borderColor = UIColor.clear
                
            } else {
                errors += 1
                self.viConfirmPassword.borderColor = UIColor.red
            }
        }
        
        
        
        completion(errors)
    }
}
