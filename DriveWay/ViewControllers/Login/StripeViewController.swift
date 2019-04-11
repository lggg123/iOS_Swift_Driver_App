//
//  StripeViewController.swift
//  Driveway
//
//  Created by imac on 5/27/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit

class StripeViewController : UIViewController {
    
    @IBOutlet weak var webview: UIWebView!
    
    var fromSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = thisUser!
        let email = user.email
     
        
        let url = API_URL_BASE + "connectStripe?email=" + email
        webview.loadRequest(URLRequest(url: URL(string: url)!))
        webview.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = "Loading..."
    }
    
    static func newInst() -> StripeViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "stripevc") as! StripeViewController
        return vc
    }
}

extension StripeViewController : UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.url?.scheme == "driveway" {
            if self.fromSetting {
                if request.url?.host == "success" {
                    User.currentLoggedUser { (user) in
                        //            SVProgressHUD.dismiss()
                        if let user = user {
                            thisUser = user
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                } else {
                    self.alertOk(title: "Stripe payment", message: "Authentication failed. Please try agin.", cancelButton: "OK", cancelHandler: nil)
                }
            } else {
                gotoViewController(id: "home")
            }
            
            return false
        } else {
            return true
        }
        
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.title = "Payment Information"
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        navigationItem.title = "Payment Information"
    }
}
