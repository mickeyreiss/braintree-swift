# Braintree Swift

A client Braintree library for Swift apps.

## Features

* Tokenize credit cards to create `payment_method_nonces`
* Vault credit cards from raw credit card details

## Usage

See [Braintree Playground](BraintreeUsage.playground).

## Minimum Requirements

* Xcode 6.1 & iOS 8.1 SDK development environment
* iOS 8+
* Braintree server-side integration, using the latest client libraries as of 11/14/14
  * An authenticated endpoint on your server that generates `client_tokens`
  * Another authenticated endpoint on your server that accepts `payment_method_nonce`s

## Project Status

:warning: Under Construction :warning: - This library is not officially supported by Braintree; use it at your own risk. [braintree_ios](https://github.com/braintre/braintree_ios), which is written in Objective-C, is fully supported and interoperable with Swift apps.

### Missing Features

* [Security] SSL Certificate Pinning
* [Functionality] Support for credit card verification data, like CVV or Postal Code
* [Functionality] Support for alternative payment methods, like PayPal and Venmo
* [UI] UI Bindings 
* [UI] Drop In

## License

Copyright (c) 2014 Braintree, a division of PayPal, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
