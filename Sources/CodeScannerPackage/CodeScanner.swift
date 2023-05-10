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
    var metaDataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero
    var maskBorderColor: UIColor = UIColor.white
    var animationDuration: Double = 0.5

    public init(result: Binding<String>, isScanned: Binding<Bool>) {
        self._result = result
        self._isScanned = isScanned
    }

    public func makeUIViewController(context: Context) -> CodeScannerViewController {
        let controller = CodeScannerViewController(delegate: context.coordinator)
        return controller
    }

    public func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
        uiViewController.boundingBoxSize = boundingBoxSize
        uiViewController.maskBorderColor = maskBorderColor
        uiViewController.animationDuration = animationDuration
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($result, $isScanned)
    }
}

extension CodeScanner {
    public func metadataObjectTypes(_ metadataObjects: [AVMetadataObject.ObjectType]) -> CodeScanner {
        var view = self
        view.metaDataObjectTypes = metadataObjects
        return view
    }

    public func boundingBoxSize(_ size: CGSize) -> CodeScanner {
        var view = self
        view.boundingBoxSize = size
        return view
    }

    public func maskBorderColor(_ color: Color) -> CodeScanner {
        var view = self
        view.maskBorderColor = UIColor(color)
        return view
    }

    func animationDuration(_ animDuration: Double) -> CodeScanner {
        var view = self
        view.animationDuration = animDuration
        return view
    }
}
