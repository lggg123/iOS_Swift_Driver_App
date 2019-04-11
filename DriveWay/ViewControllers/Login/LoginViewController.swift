//
//  LoginViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SVProgressHUD
import GoogleSignIn

class LoginViewController : UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var loaded = false
    var connectedRef : DatabaseReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.delegate = self
        tfPassword.delegate = self
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        connectedRef = Database.database().reference(withPath: ".info/connected")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = Auth.auth().currentUser, !loaded {
            loaded = true
            
            connectedRef?.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    SVProgressHUD.show()
                    
                    User.currentLoggedUser(completion: { (user) in
                        SVProgressHUD.dismiss()
                        if let user = user {
                            thisUser = user
                            
                            if user.type == .admin {
                                gotoViewController(id: "adminnvc")
                            } else if user.banned {
                                self.alertOk(title: "Login Error", message: "You are banned and could not log in", cancelButton: "OK", cancelHandler: nil)
                            } else if user.stripeAccountID == nil || user.stripeCustomerID == nil {
                                self.alertOk(title: "Login Error", message: "Please complete your payment setup before log in", cancelButton: "OK", cancelHandler: { (_) in
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "stripevc")
                                    self.navigationController?.pushViewController(vc, animated: true)
                                })
                            } else {
                                gotoViewController(id: "home")
                            }
                        }
                    })
                    self.connectedRef?.removeAllObservers()
                    
                } else {
                    //                    alertOk(title: "No Internet Connection", message: "Please connect to the internet and restart the app.", cancelButton: "OK", cancelHandler: nil, viewController: self)
                }
                
            })
        }
    }
    
    @IBAction func onSignin(_ sender: Any) {
        var email = self.tfEmail.text!
        var password = self.tfPassword.text!
        
        self.view.endEditing(true)
        
        self.connectedRef?.removeAllObservers()
        
        email = email.trimmingCharacters(in: CharacterSet.whitespaces)
        password = password.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if email == "" {
            alertOk(title: "Login Error", message: "Please enter your email", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        if password == "" {
            alertOk(title: "Login Error", message: "Please enter your password", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        if !email.contains("@") || !isEmailValid(email: email){
            alertOk(title: "Login Error", message: "Please enter valid email address", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        if reachability.connection == .none {
            alertOk(title: "Login Error", message: "No internet connectivity detected.", cancelButton: "OK", cancelHandler: nil)
            return
        }
        SVProgressHUD.dismiss()
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                SVProgressHUD.dismiss()
                
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                        self.alertForOtherCredential(email: email)
                    }
                    else if errorCode == AuthErrorCode.userNotFound {
                        
                        self.alert(title: "Login Error", message: "This email does not exist in our records. Please try again or sign up to new account.", okButton: "Sign up", cancelButton: "Try again", okHandler: { (_) in
                            if let storyboard = self.storyboard {
                                let vc = storyboard.instantiateViewController(withIdentifier: "signupvc") as! SignupViewController
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }, cancelHandler: nil)
                    } else if errorCode == AuthErrorCode.wrongPassword {
                        self.alertOk(title: "Login Error", message: "Incorrect password. Please try again.", cancelButton: "OK", cancelHandler: nil)
                    }else {
                        self.alertOk(title: "Login Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    }
                }
            } else {
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set("email", forKey:"signinMethod");
                
                User.currentLoggedUser(completion: { (user) in
                    SVProgressHUD.dismiss()
                    
                    if let user = user {
                        thisUser = user
                        if user.type == .admin {
                            gotoViewController(id: "adminnvc")
                        } else if user.banned {
                            self.alertOk(title: "Login Error", message: "You are banned and could not log in", cancelButton: "OK", cancelHandler: nil)
                        } else if user.stripeAccountID == nil || user.stripeCustomerID == nil {
                            self.alertOk(title: "Login Error", message: "Please complete your payment setup before log in", cancelButton: "OK", cancelHandler: { (_) in
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "stripevc")
                                self.navigationController?.pushViewController(vc, animated: true)
                            })
                        } else {
                            gotoViewController(id: "home")
                        }
                        
                    } else {
                        //case: tried signed up, but not completed
                        do {
                            try Auth.auth().signOut()
                        }
                        catch {
                            
                        }
                        
                        self.alertOk(title: "Login Error", message: "Something wrong with your profile information. Please contact customer support.", cancelButton: "OK", cancelHandler: nil)
                    }
                })
                
            }
        })
    }
    @IBAction func onFacebook(_ sender: Any) {
        self.connectedRef?.removeAllObservers()
        
        if reachability.connection == .none {
            alertOk(title: "Login Error", message: "No internet connectivity detected.", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.show()
        
        let login = FBSDKLoginManager()
        login.logOut()
        
        login.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Facebook Login", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
            } else if let cancelled = result?.isCancelled, cancelled {
                SVProgressHUD.dismiss()
                self.alertOk(title: "Facebook Login", message: "Signin by facebook canceled", cancelButton: "OK", cancelHandler: nil)
            } else if (FBSDKAccessToken.current() != nil){
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,first_name,last_name,picture"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET") {
                        req.start(completionHandler: { (connection, result, ferror) in
                            if(ferror == nil)
                            {
                                if let info = result as? [String:Any], let email = info["email"] as? String {
                                    let imageURL = "https://graph.facebook.com/\(String(describing: info["id"]!))/picture?type=normal"
                                    UserDefaults.standard.set(info["first_name"], forKey: "firstName")
                                    UserDefaults.standard.set(info["last_name"], forKey: "lastName")
                                    UserDefaults.standard.set(imageURL, forKey: "picture")
                                    
                                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                                        if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                                            SVProgressHUD.dismiss()
                                            self.alertForOtherCredential(email: email)
                                        } else {
                                            DispatchQueue.main.async {
                                                SVProgressHUD.dismiss()
                                                self.alertOk(title: "Facebook Login", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                                            }
                                        }
                                        
                                    } else {
                                        UserDefaults.standard.set("facebook", forKey: "lastSignedInMethod")
                                        self.doSignIn(user: user, firstName: info["first_name"] as! String, lastName: info["last_name"] as! String, photoURL: imageURL)
                                    }
                                    
                                    
                                    
                                }
                                
                                
                            }
                            else
                            {
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    self.alertOk(title: "Login Error", message: "Can not log in with facebook. Please try again.", cancelButton: "OK", cancelHandler: nil)
                                }
                            }
                        })
                        
                    } else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.alertOk(title: "Login Error", message: "Can not log in with facebook. Please try again.", cancelButton: "OK", cancelHandler: nil)
                        }
                    }
                    
                    
                    
                    //                    let parameters:[String:String] = [:]
                    //                    parameters["fields"] = "id,name,email"
                    //
                    //                    FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) in
                    //
                    //                    })
                    
                    
                })
            } else {
                SVProgressHUD.dismiss()
                print("Exception?")
            }
        }
    }
    @IBAction func onGoogle(_ sender: Any) {
        self.connectedRef?.removeAllObservers()
        
        if reachability.connection == .none {
            alertOk(title: "Login Error", message: "No internet connectivity detected.", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.show()
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func alertForOtherCredential(email: String) {
        Auth.auth().fetchProviders(forEmail: email, completion: { (providers, error) in
            if error == nil {
                if providers?[0] == "google.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login Error", message: "You already signed in with Google. Please sign in with Google.", cancelButton: "OK", cancelHandler: nil)
                    }
                } else if providers?[0] == "facebook.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login Error", message: "You already signed in with Facebook. Please sign in with Facebook.", cancelButton: "OK", cancelHandler: nil)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login Error", message: "You already signed in with email. Please use email to log in.", cancelButton: "OK", cancelHandler: nil)
                    }
                }
            } else {
                
            }
        })
    }
}
extension LoginViewController :GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            SVProgressHUD.dismiss()
            
            alertOk(title: "Google Signin", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
            
            return
        }
        
        let email = user.profile.email
        let firstName = user.profile.givenName ?? " "
        let lastName = user.profile.familyName ?? " "
        let picture = user.profile.imageURL(withDimension: 400).absoluteString
        
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(picture, forKey: "picture")
        
        Auth.auth().fetchProviders(forEmail: email!, completion: { (providers, error) in
            
            if error == nil {
                
                if let provider = providers?[0], provider != "google.com" {
                    let providerName = (provider == "facebook.com" ? "Facebook" : "Email")
                    SVProgressHUD.dismiss()
                    self.alert(title: "Google Signin", message: "Sign in with Google will replace your previous \(providerName) signin. Are you sure want to proceed?", okButton: "OK", cancelButton: "Cancel", okHandler: { (_) in
                        SVProgressHUD.show()
                        self.continueGoogleSignIn(user: user, email: email!, firstName: firstName, lastName: lastName, photoURL: picture)
                    }, cancelHandler: nil)
                    return
                }
            }
            self.continueGoogleSignIn(user:user, email: email!, firstName: firstName, lastName: lastName, photoURL: picture)
        })
        
    }
    
    func continueGoogleSignIn(user: GIDGoogleUser, email: String, firstName: String, lastName: String, photoURL: String) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                SVProgressHUD.dismiss()
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                        
                        
                        self.alertForOtherCredential(email: email)
                    } else {
                        self.alertOk(title: "Google Signin", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    }
                    return
                }
            }
            
            self.doSignIn(user: user, firstName: firstName, lastName: lastName, photoURL: photoURL)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func doSignIn(user: Firebase.User?, firstName: String, lastName: String, photoURL: String) {
        User.currentLoggedUser { (user) in
            //            SVProgressHUD.dismiss()
            if let user = user {
                thisUser = user
                
                if user.type == .admin {
                    gotoViewController(id: "adminnvc")
                } else if user.banned {
                    self.alertOk(title: "Login Error", message: "You are banned and could not log in", cancelButton: "OK", cancelHandler: nil)
                } else if user.stripeAccountID == nil || user.stripeCustomerID == nil {
                    self.alertOk(title: "Login Error", message: "Please complete your payment setup before log in", cancelButton: "OK", cancelHandler: { (_) in
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "stripevc")
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                } else {
                    gotoViewController(id: "home")
                }
                
            } else {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "signup4vc") as! Signup4ViewController
                vc.isSocial = true
                vc.firstName = firstName
                vc.lastName = lastName
                vc.photoURL = photoURL
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        } else if textField == tfPassword {
            tfPassword.resignFirstResponder()
        }
        return true
    }
}

