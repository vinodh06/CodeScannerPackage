//
//  CodeScanner.swift
//
//
//  Created by vinodh kumar on 11/04/23.
//

import UIKit
import SwiftUI
import AVFoundation

public struct CodeScanner: UIViewControllerRepresentable {

    @Binding public var result:             String?
    @Binding public var isSessionStarted:   Bool
    @Binding public var isCameraSupported:  Bool
    @Binding public var hasCameraAccess:    Bool

    var metadataObjectTypes: [AVMetadataObject.ObjectType] = []

    public init(
        result: Binding<String?>,
        isSessionStarted: Binding<Bool> = .constant(false),
        isCameraSupported: Binding<Bool> = .constant(false),
        hasCameraAccess: Binding<Bool> = .constant(false)
    ) {
        _result             = result
        _isSessionStarted   = isSessionStarted
        _isCameraSupported  = isCameraSupported
        _hasCameraAccess    = hasCameraAccess
    }

    public func makeUIViewController(context: Context) -> CodeScannerViewController {
        CodeScannerViewController(
            delegate: context.coordinator,
            codeScannerDelegate: context.coordinator
        )
    }

    public func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
        uiViewController.metadataObjectTypes    = metadataObjectTypes
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            metadataObjectTypes: metadataObjectTypes,
            scanResult: $result,
            isSessionStarted: $isSessionStarted,
            isCameraSupported: $isCameraSupported,
            hasCameraAccess: $hasCameraAccess
        )
    }
}

extension CodeScanner {
    public func metadataObjectTypes(_ metadataObjects: [AVMetadataObject.ObjectType]) -> CodeScanner {
        var view                    = self
        view.metadataObjectTypes    = metadataObjects
        return view
    }
}
