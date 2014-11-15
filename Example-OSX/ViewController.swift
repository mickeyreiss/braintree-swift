//
//  ViewController.swift
//  Example-OSX
//
//  Created by Mickey Reiss on 11/14/14.
//  Copyright (c) 2014 Braintree. All rights reserved.
//

import Cocoa
import Braintree

class ViewController: NSViewController {
    @IBOutlet var nonceLabel : NSTextField!

    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
        delegate: nil,
        delegateQueue: NSOperationQueue.mainQueue())

    let baseURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/")

    @IBAction func demonstrateTokenization(sender: NSButton) {
        let clientTokenProvider : Braintree.ClientTokenProvider = { [weak self] completion in
            if let baseURL = self?.baseURL {
                if let URL : NSURL = NSURL(string: "/client_token", relativeToURL: baseURL) {
                    if let session = self?.session {
                        session.dataTaskWithURL(URL, completionHandler: { (data, response, error) -> Void in
                            if let data = data {
                                let clientTokenResponseObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as Dictionary<String,String>
                                if let clientToken : String = clientTokenResponseObject["client_token"] as String? {
                                    completion(clientToken)
                                }
                            }
                        }).resume()
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }

        let braintree = Braintree(clientTokenProvider: clientTokenProvider)

        let card = Braintree.PaymentMethodDetails.Card(number: "4111111111111111", expiration: Braintree.Expiration(expirationMonth: 12, expirationYear: 2015))

        nonceLabel.alphaValue = 0.0
        braintree.tokenize(card, completion: { [weak self] (response) -> (Void) in
            switch response {
            case let .PaymentMethodNonce(nonce):
                self?.nonceLabel.alphaValue = 1.0
                self?.nonceLabel.stringValue = nonce
            case let .RequestError(message):
                println("Request error: \(message)")
            case let .BraintreeError(message):
                println("Braintree error: \(message)")
            }
        })
    }
}

