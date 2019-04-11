//
//  BookingPayViewController.swift
//  Driveway
//
//  Created by imac on 4/30/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import UIKit
import Stripe
import SVProgressHUD

class BookingPayViewController : UIViewController {
    var spot: ParkingSpot!
    var bookQuery: BookQuery!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDates: UILabel!
    @IBOutlet weak var lblBookType: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var viPaymentDetail: UIView!
    var paymentRow: CheckoutRowView!
    let rowHeight: CGFloat = 44
    
    private var customerContext: STPCustomerContext!
    private var paymentContext: STPPaymentContext!
    private var totalPriceInCents: Int {
        return Int(self.spot.price(bookQuery: self.bookQuery) * 100)
    }
    
    private var chargeID: String? = nil
    
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    SVProgressHUD.show()
                }
                else {
                    SVProgressHUD.dismiss()
                }
            }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stripe init
        
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = stripePublishableKey
        config.companyName = thisUser!.displayName
        config.createCardSources = true
        
        let theme = STPTheme.default()
        
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: theme)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = totalPriceInCents
        paymentContext.paymentCurrency = "usd"
        
        self.paymentRow = CheckoutRowView(title: "Payment", detail: "Select Payment",
                                          theme: theme)
        self.viPaymentDetail.addSubview(paymentRow)
        
        
        self.paymentRow.onTap = { [weak self] in
            self?.paymentContext.pushPaymentMethodsViewController()
        }
        
        self.initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = viPaymentDetail.bounds.size.width
        self.paymentRow.frame = CGRect(x: 0, y: 0, width: width, height: rowHeight)
    }
    
    @IBAction func onPay(_ sender: Any) {
        let price = self.spot.price(bookQuery: self.bookQuery)
        
        print("need to pay: \(price.clean)")
        
        
        self.paymentInProgress = true
        self.paymentContext.requestPayment()

    }
    
    func initUI() {
        lblTitle.text = spot.title
        lblUserName.setNameFor(userID: spot.userID, prefix: "Hosted by ")
        lblLocation.text = spot.address
        
        guard let dateFrom = bookQuery.dateFrom, let dateTo = bookQuery.dateTo, let hourFrom = bookQuery.hourFrom, let hourTo = bookQuery.hourTo, let bookType = bookQuery.type else {
            return
        }
        
        let dateFromStr = dateFrom.toString(format: "MMMM dd, yyyy")
        let dateToStr = dateTo.toString(format: "MMMM dd, yyyy")
        lblDates.text = "\(dateFromStr) - \(dateToStr)"
        
        if bookType == .hourly {
            let timeStr = "From \(times[hourFrom]) to \(times[hourTo])"
            lblBookType.text = "\(bookType.rawValue) \(timeStr)"
        } else {
            lblBookType.text = "Daily"
        }
        
        
        let price = spot.price(bookQuery: self.bookQuery)
        
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: dateFrom, to: dateTo).day {
            if bookType == .daily {
                
                lblTotalPrice.text = days == 0 ? "$\(price) for 1 day" : "$\(price) for \(days+1) days"
            } else {
                let hours = hourTo - hourFrom
                assert(hours >= 0)
                
                lblTotalPrice.text = days == 0 ? "$\(price) for 1 day" : "$\(price) for \(days+1) days"
            }
        }
    }
    
    static func newInst(spot: ParkingSpot, bookQuery: BookQuery) -> UIViewController {
        let vc = UIStoryboard(name: "CustomerHome", bundle: nil).instantiateViewController(withIdentifier: "bookingpayvc") as! BookingPayViewController
        
        vc.spot = spot
        vc.bookQuery = bookQuery
        
        return vc
    }
}


extension BookingPayViewController : STPPaymentContextDelegate {
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentRow.loading = paymentContext.loading
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            self.paymentRow.detail = paymentMethod.label
        }
        else {
            self.paymentRow.detail = "Select Payment"
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("paymentcontext:didFailToLoadWithError")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        print("paymentContext:didFinishWith:status")
        
        self.paymentInProgress = false
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
            
            self.alertOk(title: "Error", message: message, cancelButton: "OK", cancelHandler: nil)
        case .success:
            title = "Success"

            self.spot.book(bookQuery: self.bookQuery) { (error, contract) in
                if let error = error {
                    self.alertOk(title: "Error", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                }
                else {
                    contract?.chargeID = self.chargeID
                    
                    contract?.save(completion: { (error, contractID) in
                        self.alertOk(title: "Success", message: "Parking spot is booked successfully", cancelButton: "OK", cancelHandler: { (_) in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    })                   
                    
                }
            }
        case .userCancellation:
            return
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("paymentContext:didCreatePaymentResult")
        
        self.chargeID = nil
        
        User.loadUser(userID: self.spot.userID) { (user) in
            if let user = user, let merchantID = user.stripeAccountID {
                if let customerID = thisUser?.stripeCustomerID {
                    MainAPIClient.shared.completeCharge(source: paymentResult.source.stripeID, amount: self.totalPriceInCents, currency: "usd", customerID: customerID, merchantID: merchantID, completion: { (chargeID, error) in
                        self.chargeID = chargeID
                        completion(error)
                    })
                } else {
                    self.paymentInProgress = false
                    self.alertOk(title: "Error", message: "Please check your payment method and stripe account", cancelButton: "OK", cancelHandler: nil)
                }
        
            } else {
                self.paymentInProgress = false
                self.alertOk(title: "Error", message: "Host is not ready to receive payment yet", cancelButton: "OK", cancelHandler: nil)
            }
        }
        
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
    }
    
}
