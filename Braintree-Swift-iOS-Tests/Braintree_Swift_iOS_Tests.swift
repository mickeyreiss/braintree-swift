import XCTest
import Braintree

class Braintree_Swift_iOS_Tests: XCTestCase {

    var braintree : Braintree.Client {
        return Braintree.Client(clientTokenProvider: clientTokenProvider)
    }

    let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
        delegate: nil,
        delegateQueue: NSOperationQueue.mainQueue())

    let baseURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com")

    lazy var clientTokenProvider : Braintree.Client.ClientTokenProvider = { [weak self] completion in
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

    func testSuccessfulCardTokenization() {
        let tokenizationCompletedSuccessfully = self.expectationWithDescription("Tokenizing a card generates a nonce")

        let expiration = Braintree.TokenizationRequest.Expiration(expirationMonth: 12, expirationYear: 2015)
        let card = Braintree.TokenizationRequest.Card(number: "4111111111111111", expiration: expiration)

        braintree.tokenize(card) { (response) -> (Void) in
            switch response {
            case let .PaymentMethodNonce(nonce: nonce):
                tokenizationCompletedSuccessfully.fulfill()
            case let .BraintreeError(message: message):
                XCTFail("Got a Braintree error while tokenizing card details: \(message)")
            case let .RequestError(message: message, fieldErrors: fieldErrors):
                XCTFail("Got a request error while tokenizing card details: \(message)")
            }
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
}
