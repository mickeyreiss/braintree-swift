import UIKit
import Braintree
import PassKit

func debug(message : String) {
    print("[Example] ")
    println(message)
}

class ViewControllerIOS: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
        delegate: nil,
        delegateQueue: NSOperationQueue.mainQueue())
    let baseURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com")
    @IBOutlet var nonceLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        nonceLabel.alpha = 0.0
    }

    var braintree : Braintree.Client {
        // Initialize a Braintree instance with the client token handler.
        debug("Initializing Braintree v\(Braintree.Version)")
        return Braintree.Client(clientTokenProvider: clientTokenProvider)
    }


    // MARK: Tokenization Demonstration

    @IBAction
    func demonstrateCardTokenization() {
        let expiration = Braintree.TokenizationRequest.Expiration(expirationMonth: 12, expirationYear: 2015)

        // Initialize a Tokenizable, such as CardDetails, based on user input.
        let card = Braintree.TokenizationRequest.Card(number: "4111111111111111", expiration: expiration)

        // Send the raw card details directly to Braintree in exchange for a payment method nonce.
        self.nonceLabel.text = nil
        self.nonceLabel.alpha = 0.0

        debug("Tokenizing Test Visa")
        braintree.tokenize(card, handleTokenization)
    }

    @IBAction
    func demonstrateApplePayTokenization() {
        let supportedNetworks = [ PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa ]

        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            return self.presentViewController(alert, animated: true, completion: nil)
        }

        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(supportedNetworks) == false {
            let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            return self.presentViewController(alert, animated: true, completion: nil)
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.braintreepayments.dev-dcopeland"
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = .Capability3DS
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "One Dollar Item", amount: NSDecimalNumber(string: "1")),
            PKPaymentSummaryItem(label: "COMPANY", amount: NSDecimalNumber(string: "1"))
        ]

        debug("Presenting Apple Pay view controller")
        let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
        authorizationViewController.delegate = self
        self.presentViewController(authorizationViewController, animated: true, completion: nil)
    }

    lazy var handleTokenization : (Braintree.TokenizationResponse) -> (Void) = { [weak self] result in
        switch result {
        case let .RequestError(message, fieldErrors):
            debug("Got a request error: \(message)\n\(fieldErrors)")
        case let .BraintreeError(message):
            debug("Got a Braintree error: \(message)")
        case let .PaymentMethodNonce(nonce):
            debug("Got a nonce: \(nonce)")

            if let nonceLabel = self?.nonceLabel {
                nonceLabel.text = nonce
                nonceLabel.alpha = 1.0
            }
        }
    }

    // MARK: Braintree Client Token generation

    lazy var clientTokenProvider : Braintree.Client.ClientTokenProvider = { [weak self] completion in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let baseURL = self?.baseURL {
            if let URL : NSURL = NSURL(string: "/client_token", relativeToURL: baseURL) {
                if let session = self?.session {
                    session.dataTaskWithURL(URL, completionHandler: { (data, response, error) -> Void in
                        if let data = data {
                            let clientTokenResponseObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as Dictionary<String,String>
                            if let clientToken : String = clientTokenResponseObject["client_token"] as String? {
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                completion(clientToken)
                            }
                        }
                    }).resume()
                } else {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(nil)
                }
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(nil)
            }
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(nil)
        }
    }

    // MARK: Apple Pay Tokenization

    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        controller
        debug("Apple Pay authorized a payment: \(payment)")
        debug("Tokenizing PKPayment")
        braintree.tokenize(.ApplePay(payment: payment)) { response in
            self.handleTokenization(response)
            switch response {
            case let .BraintreeError(message: _):
                completion(.Failure)
            case let .RequestError(message: _, fieldErrors: _):
                completion(.Failure)
            case let .PaymentMethodNonce(nonce: _):
                completion(.Success)
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        debug("Dismissing Apple Pay view controller")
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}