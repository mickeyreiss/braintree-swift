import Braintree
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

// Obtain a client token from your server in this block.
var clientTokenHandler : Braintree.Client.ClientTokenProvider = { completion in
    // Note: This value is hard-coded only for the sake of this exmaple. In your integration, you
    // should obtain a fresh client token via from an authenticated endpoint on your server.
    completion("eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIwM2FjZGJjNTAxMjI0ZjMwMWUyMGE2MTIxOTNlM2QzMzViNjJlOTIzZjQwYjhkZjRiZTEzOTMwMjlhODI1YWJjfGNyZWF0ZWRfYXQ9MjAxNC0xMS0xNFQxODozNjoyMi4zOTkxNjM2OTIrMDAwMFx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwicGF5bWVudEFwcHMiOltdLCJjbGllbnRBcGlVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhdXRoVXJsIjoiaHR0cHM6Ly9hdXRoLnZlbm1vLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhbmFseXRpY3MiOnsidXJsIjoiaHR0cHM6Ly9jbGllbnQtYW5hbHl0aWNzLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6ZmFsc2UsInBheXBhbEVuYWJsZWQiOnRydWUsInBheXBhbCI6eyJkaXNwbGF5TmFtZSI6IkFjbWUgV2lkZ2V0cywgTHRkLiAoU2FuZGJveCkiLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiYWxsb3dIdHRwIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6dHJ1ZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6ZmFsc2UsIm1lcmNoYW50SWQiOiJkY3BzcHkyYnJ3ZGpyM3FuIiwidmVubW8iOiJvZmZsaW5lIiwiYXBwbGVQYXkiOnsic3RhdHVzIjoibW9jayIsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJVU0QiLCJtZXJjaGFudElkZW50aWZpZXIiOiJtZXJjaGFudC5jb20uYnJhaW50cmVlcGF5bWVudHMuZGV2LWRjb3BlbGFuZCIsInN1cHBvcnRlZE5ldHdvcmtzIjpbInZpc2EiLCJtYXN0ZXJjYXJkIiwiYW1leCJdfX0=")
}

// Initialize a Braintree instance with the client token handler.
let braintree = Braintree.Client(clientTokenProvider: clientTokenHandler)

// Initialize a Tokenizable, such as CardDetails, based on user input.
let expiration = Braintree.TokenizationRequest.Expiration(expirationMonth: 12, expirationYear: 2015)

let card = Braintree.TokenizationRequest.Card(number: "4111111111111111", expiration: expiration)

// Send the raw card details directly to Braintree in exchange for a payment method nonce.
braintree.tokenize(card) { result in
    switch result {
    case let .RequestError(message):
        println("Got an error: \(message)")
        XCPCaptureValue("Braintree tokenization request error", message)
    case let .BraintreeError(message):
        println("Got a Braintree error: \(message)")
        XCPCaptureValue("Braintree tokenization internal error", message)
    case let .PaymentMethodNonce(nonce):
        println("Got a nonce: \(nonce)")
        XCPCaptureValue("Braintree tokenization nonce", nonce)
    }
}

XCPSetExecutionShouldContinueIndefinitely()
