import UIKit
import Braintree

func debug(message : String) {
    print("[Example] ")
    println(message)
}

class ViewController: UIViewController {
    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
        delegate: nil,
        delegateQueue: NSOperationQueue.mainQueue())
    let baseURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com")

    @IBOutlet var nonceLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nonceLabel.alpha = 0.0
    }

    @IBAction
    func demonstrateTokenization() {
        let clientTokenProvider : Braintree.ClientTokenProvider = { [weak self] completion in
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

        // Obtain a client token from your server in this block.

        // Initialize a Braintree instance with the client token handler.
        debug("Initializing Braintree v\(Braintree.Version)")
        let braintree = Braintree(clientTokenProvider: clientTokenProvider)

        let expiration = Braintree.Expiration(expirationMonth: 12, expirationYear: 2015)

        // Initialize a Tokenizable, such as CardDetails, based on user input.
        let card = Braintree.PaymentMethodDetails.Card(number: "4111111111111111", expiration: expiration)

        // Send the raw card details directly to Braintree in exchange for a payment method nonce.
        self.nonceLabel.text = nil
        self.nonceLabel.alpha = 0.0

        debug("Tokenizing Test Visa")
        braintree.tokenize(card) { [weak self] result in
            switch result {
            case let .RequestError(message):
                debug("Got an error: \(message)")
            case let .InternalError(message):
                debug("Got an error: \(message)")
            case let .PaymentMethodNonce(nonce):
                debug("Got a nonce: \(nonce)")

                self?.nonceLabel.text = nonce
                self?.nonceLabel.alpha = 1.0
            }
        }
    }
}
