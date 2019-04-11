//
//  Signup4ViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

import Photos
import Firebase
import SVProgressHUD
import GooglePlaces
import GooglePlacePicker
import KMPlaceholderTextView

class Signup4ViewController : UIViewController {
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tvAbout: KMPlaceholderTextView!
    
    @IBOutlet weak var btnCustomer: UIButton!
    @IBOutlet weak var btnHost: UIButton!
    
    @IBOutlet weak var viAbout: UIView!
    var email: String!
    var password: String!
    
    var avatarLoaded = false
    
    //for social signup
    var firstName: String?
    var lastName: String?
    var photoURL: String?
    
    var isSocial: Bool = false
    
    var userType: UserType = .customer {
        didSet {
            if userType == .host {
                btnCustomer.isSelected = false
                btnHost.isSelected = true
                viAbout.isHidden = false
            } else {
                btnCustomer.isSelected = true
                btnHost.isSelected = false
                viAbout.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onUploadPhoto))
        tap.numberOfTapsRequired = 1
        imgPhoto.isUserInteractionEnabled = true
        imgPhoto.addGestureRecognizer(tap)
        
        userType = .customer
        
        if let user = Auth.auth().currentUser, isSocial {
            self.email = user.email
            self.password = ""
            
            tfFirstName.text = self.firstName
            tfLastName.text = self.lastName
            isSocial = true
            
            tfFirstName.isEnabled = false
            tfLastName.isEnabled = false
            
            if let _photoURL = self.photoURL {
                imgPhoto.sd_setImage(with: URL(string: _photoURL))
                avatarLoaded = true
            }
        } else {
            do {
                try Auth.auth().signOut()
            }
            catch {
                
            }
        }
        
    }
    
    @IBAction func onCustomer(_ sender: Any) {
        userType = .customer
    }
    
    @IBAction func onHost(_ sender: Any) {
        userType = .host
    }
    
    @objc func onUploadPhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            UIViewController.takePhoto(viewController: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Select from gallery", style: .default, handler: { (action) in
            UIViewController.loadFromGallery(viewController: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        let _firstName = tfFirstName.text!
        let _lastName = tfLastName.text!
        
        var errors = 0
        
        self.view.endEditing(true)
        
        if reachability.connection == .none {
            alertOk(title: "No Internet Connection", message: "Please connect to the internet and try again.", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        var trimmed = _firstName.trimmingCharacters(in: .whitespaces)
        
        if trimmed == "" || _firstName.length < 1 || _firstName.length > 20 || !isNameValid(name: _firstName){
            errors += 1
            
            alertOk(title: "Sign Up", message: "First name is invalid", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        trimmed = _lastName.trimmingCharacters(in: .whitespaces)
        
        if trimmed == "" || _lastName.length < 1 || _lastName.length > 20 || !isNameValid(name: _firstName){
            errors += 1
            
            alertOk(title: "Sign Up", message: "Last name is invalid", cancelButton: "OK", cancelHandler: nil)
            return
        }

        if userType == .host {
            trimmed = tvAbout.text.trimmingCharacters(in: .whitespaces)
            
            if trimmed == "" || trimmed.length < 10 {
                self.alertOk(title: "Sign Up", message: "Please input input more than 10 characters", cancelButton: "OK", cancelHandler: nil)
                return
            }
        }
        
        if errors > 1 {
            alertOk(title: "Sign Up", message: "We detected a few errors. Help me review your answers and try again.", cancelButton: "OK", cancelHandler: nil)
        } else if errors == 1 {
            alertOk(title: "Sign Up", message: "We detected an error. Help me review your answer and try again.", cancelButton: "OK", cancelHandler: nil)
        } else {
            if let email = self.email, let password = self.password {
               
                SVProgressHUD.show()
                
                if let _ = Auth.auth().currentUser {
                    //if already signed up via social login, do just setup user
                    uploadImageAndSetupUserInfo()
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        
                        
                        if let error = error {
                            SVProgressHUD.dismiss()
                            self.alertOk(title: "Sign Up", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                            return
                        }
                        
                        self.uploadImageAndSetupUserInfo()
                    })
                }
            }
        }
    }
    
    func uploadImageAndSetupUserInfo() {
        if avatarLoaded, isSocial {
            self.setupUserInfo(imageURL: self.photoURL)
        } else if avatarLoaded, let image = self.imgPhoto.image {
            let path = curid()! + "/" + timestamp() + ".png"
            
            
            let resized = image.resized(toWidth: 200, toHeight: 200)
            uploadImageTo(path: path, image: resized, completionHandler: { (downloadURL, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.alertOk(title: "Uploading Profile Image", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    return
                }
                
                if let url = downloadURL {
                    self.setupUserInfo(imageURL: url)
                    
                } else {
                    self.setupUserInfo(imageURL: nil)
                }
            })
        } else {
            self.setupUserInfo(imageURL: nil)
        }
    }
    
    func setupUserInfo(imageURL: String?) {
        let changeRequest = curuser()!.createProfileChangeRequest()
        let firstName = tfFirstName.text!
        let lastName = tfLastName.text!
        let displayName = firstName + " " + lastName
        let email = curuser()!.email!
        
        changeRequest.displayName = displayName
        
        if let url = imageURL {
            changeRequest.photoURL = URL(string: url)
        }
        
        changeRequest.commitChanges { (error) in
            if let error = error {
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.alertOk(title: "Sign Up", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                }
                return
            } else {
                // setup user information in db
                var userData:[String:Any] = [:]
                
                if let url = imageURL {
                    userData[Users.photoURL] = url
                }
                userData[Users.type] = self.userType.rawValue
                userData[Users.email] = email
                userData[Users.firstName] = firstName
                userData[Users.lastName] = lastName
                userData[Users.photoURL] = imageURL
                userData[Users.userID] = curid()!
                
                userData[Users.createdAt] = ServerValue.timestamp()
                
                let about = self.tvAbout.text!
                if self.userType == .host {
                    userData[Users.about] = about
                }
                
                
                ref().child(C.Root.users).child(curid()!).setValue(userData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        SVProgressHUD.dismiss()
                        self.alertOk(title: "Sign Up", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                        
                        return
                    } else {
                        User.currentLoggedUser(completion: { (user) in
                            SVProgressHUD.dismiss()
                            if let user = user {
                                thisUser = user
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "stripevc")
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                self.alertOk(title: "Sign Up", message: "Something wrong with your profile information. Please contact customer support.", cancelButton: "OK", cancelHandler: nil)
                            }
                        })
                        
                    }
                })
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
}

extension Signup4ViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgPhoto.image = chosenImage
            avatarLoaded = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


