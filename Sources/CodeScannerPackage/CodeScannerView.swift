//
//  SwiftUIView.swift
//
//
//  Created by vinodh kumar on 11/04/23.
//

import SwiftUI
import AVFoundation

public struct CodeScannerView: View {
    @State var scanResult = ""
    @State var isScanned = false

    @Binding var showScanner: Bool
    var metaDataObjectTypes: [AVMetadataObject.ObjectType]
    var boundingBoxSize: CGSize
    var output: (String) -> Void

    public init(showScanner: Binding<Bool>, metaDataObjectTypes: [AVMetadataObject.ObjectType], boundingBoxSize: CGSize = CGSize(width: 200, height: 200), output: @escaping (String) -> Void) {
        self._showScanner = showScanner
        self.metaDataObjectTypes = metaDataObjectTypes
        self.boundingBoxSize = boundingBoxSize
        self.output = output
    }

    public var body: some View {
        CodeScanner(result: $scanResult, isScanned: $isScanned, metaDataObjectTypes: metaDataObjectTypes, boundingBoxSize: boundingBoxSize)
        .onChange(of: isScanned) { _ in
            showScanner = false
            output(scanResult)
        }
    }
}

