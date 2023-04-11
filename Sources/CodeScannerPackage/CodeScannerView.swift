//
//  SwiftUIView.swift
//  
//
//  Created by vinodh kumar on 11/04/23.
//

import SwiftUI
import AVFoundation

struct CodeScannerView: View {
    @State var scanResult = ""
    @State var isScanned = false

    @Binding var showScanner: Bool
    var metaDataObjectTypes: [AVMetadataObject.ObjectType]
    var output: (String) -> Void

    var body: some View {
        CodeScanner(result: $scanResult, isScanned: $isScanned, metaDataObjectTypes: metaDataObjectTypes)
        .onChange(of: isScanned) { _ in
            showScanner = false
            output(scanResult)
        }
    }
}
