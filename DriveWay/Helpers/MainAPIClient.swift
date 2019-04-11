//
//  MainAPIClient.swift
//  Driveway
//
//  Created by imac on 5/27/18.
//  Copyright © 2018 Mobile Team. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Stripe

class MainAPIClient: NSObject, STPEphemeralKeyProvider {
    static let shared = MainAPIClient()
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let endpoint = "api/ephemeral_keys"
        
        guard
            !API_URL_BASE.isEmpty,
            //            let baseURL = URL(string: API_URL_BASE),
            let url = URL(string: API_URL_BASE + endpoint),
            let user = thisUser,
            let customerId = user.stripeCustomerID else {
                completion(nil, CustomerKeyError.missingBaseURL)
                return
        }
        
        
        let parameters: [String: Any] = ["api_version": apiVersion, "stripe_customer_id": customerId]
        print(parameters)
        
        Alamofire.request(url, method: .post, parameters: parameters).validate(statusCode: 200..<300)
            .responseJSON { (response) in
            guard let json = response.result.value as? [AnyHashable: Any] else {
                print("ephermal error:" + response.error.debugDescription)
                completion(nil, CustomerKeyError.invalidResponse)
                return
            }
            
            completion(json, nil)
        }
    }
    
    enum RequestOrderError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func completeCharge(source: String, amount: Int, currency: String, customerID: String, merchantID: String, completion: @escaping (String?, Error?) -> Void) {
        let endpoint = "api/order"
        
        guard
            !API_URL_BASE.isEmpty,
            let url = URL(string: API_URL_BASE + endpoint) else {
                completion(nil, RequestOrderError.missingBaseURL)
                return
        }
        
        // Important: For this demo, we're trusting the `amount` and `currency` coming from the client request.
        // A real application should absolutely have the `amount` and `currency` securely computed on the backend
        // to make sure the user can't change the payment amount from their web browser or client-side environment.
        let parameters: [String: Any] = [
            "source": source,
            "amount": amount,
            "currency": currency,
            "customer_id": customerID,
            "merchant_id": merchantID,
            ]
        
        Alamofire.request(url, method: .post, parameters: parameters).validate(statusCode: 200..<300)
            .responseJSON { (response) in
                
                
                switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: Any] else {
                        completion(nil, RequestOrderError.invalidResponse)
                        return
                    }
                    
                    guard let chargeId = json["charge_id"] as? String
                        else {
                            print(json)
                            
                            completion(nil, RequestOrderError.invalidResponse)
                            return
                    }
                    
                    completion(chargeId, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
}
