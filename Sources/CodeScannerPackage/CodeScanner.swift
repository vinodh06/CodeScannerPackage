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

    @Binding public var result: String
    @Binding public var isScanned: Bool
    public var metaDataObjectTypes: [AVMetadataObject.ObjectType]
    public var boundingBoxSize: CGSize

    public func makeUIViewController(context: Context) -> CodeScannerViewController {
        let controller = CodeScannerViewController(delegate: context.coordinator, metaDataObjectTypes: metaDataObjectTypes, boundingBoxSize: boundingBoxSize)
        return controller
    }

    public func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($result, $isScanned, metaDataObjectTypes: metaDataObjectTypes, boundingBoxSize: boundingBoxSize)
    }
}

