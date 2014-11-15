test:
	xctool -scheme Braintree-Swift-iOS -sdk macosx10.10 test
	xctool -scheme Braintree-Swift-OSX -sdk iphonesimulator test
	xctool -scheme Braintree-Swift-Example-iOS -sdk iphonesimulator test
	xctool -scheme Braintree-Swift-Example-OSX -sdk macosx10.10 test

.PHONY: test
