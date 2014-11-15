test: ios osx

ios:
	xctool -scheme Braintree-Swift-iOS -sdk iphonesimulator8.1 test
	xctool -scheme Braintree-Swift-Example-iOS -sdk iphonesimulator8.1 test

osx:
	xctool -scheme Braintree-Swift-OSX -sdk iphonesimulator test
	xctool -scheme Braintree-Swift-Example-OSX -sdk macosx10.10 test

.PHONY: test
.PHONY: ios
.PHONY: osx
