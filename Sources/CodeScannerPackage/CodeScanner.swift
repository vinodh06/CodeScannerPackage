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

    @Binding public var result: String?
    var metaDataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero
    var maskBorderColor: UIColor = UIColor.white
    var animationDuration: Double = 0.5
    var isAnimateScanner: Bool = true

    public init(result: Binding<String?>) {
        _result = result
    }

    public func makeUIViewController(context: Context) -> CodeScannerViewController {
        CodeScannerViewController(delegate: context.coordinator)
    }

    public func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
        uiViewController.boundingBoxSize = boundingBoxSize
        uiViewController.maskBorderColor = maskBorderColor
        uiViewController.animationDuration = animationDuration
        uiViewController.isAnimateScanner = isAnimateScanner
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($result)
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

    public func animationDuration(_ animationDuration: Double) -> CodeScanner {
        var view = self
        view.animationDuration = animationDuration
        return view
    }

    public func animateScanner(_ isAnimateScanner: Bool) -> CodeScanner {
        var view = self
        view.isAnimateScanner = isAnimateScanner
        return view
    }
}
