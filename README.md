# CodeScannerPackage

CodeScannerPackage is a package for scanning metadata objects such as barcodes and QR codes in SwiftUI (supported for iOS platform).


## Implementation:

1. Import the CodeScannerPackage into the SwiftUI view file where you want to add the scanner view.

2. And then create a scanner view like this one

CodeScannerView(showScanner: $showScanner, metadataObjectTypes: [.ean8, .ean13]) { barCode in print(barCode)
}

There are 3 parameters that must be passed when initialising CodeScannerView

1. showScanner - sends the binding bool variable to show or hide the scanner. Once the code is scanned, this variable is set to false to close the scanner view.

2. metadataObjectTypes - sends the metadata objects in this argument.

For barcode - [.ean8, .ean13, .pdf417...] must be sent

for QRCode - [.qr] must be sent

pass the metadata object as needed.

Please refer to the metadata links below.

See this link for the metadata objecttypes supported in iOS (barcodes and QR codes) https://developer.apple.com/documentation/avfoundation/avmetadataobject/objecttype

See this link for different types of barcodes.
https://blogs.sap.com/2013/10/23/printing-in-bar-code-in-sap-ehs-wwi/

3. The last argument is the completion handler that you use to get the scanned code.
