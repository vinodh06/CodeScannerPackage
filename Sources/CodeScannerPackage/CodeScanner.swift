//
//  CodeScanner.swift
//
//
//  Created by vinodh kumar on 11/04/23.
//

import UIKit
import SwiftUI
import AVFoundation

public typealias FailureAlertText = (title: String, description: String)

public struct CodeScanner: UIViewControllerRepresentable {

    @Binding public var result: String?

    var metaDataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero
    var maskBorderColor: UIColor = UIColor.white
    var animationDuration: Double = 0.5
    var showScannerBox: Bool = true
    var failureAlertTexts: (String, String)

    public init(result: Binding<String?>, failureAlertTitle: String? = nil, failureAlertDescription: String? = nil) {
        _result = result
        self.failureAlertTexts = FailureAlertText(
            title: failureAlertTitle ?? Constants.cameraFailureTitle(),
            description: failureAlertDescription ?? Constants.cameraFailureDescription()
        )
    }

    public func makeUIViewController(context: Context) -> CodeScannerViewController {
        CodeScannerViewController(failureAlertTexts: failureAlertTexts, delegate: context.coordinator)
    }

    public func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
        uiViewController.boundingBoxSize = boundingBoxSize
        uiViewController.maskBorderColor = maskBorderColor
        uiViewController.animationDuration = animationDuration
        uiViewController.showScannerBox = showScannerBox
        uiViewController.metaDataObjectTypes = metaDataObjectTypes
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

    public func animateScanner(_ showScannerBox: Bool) -> CodeScanner {
        var view = self
        view.showScannerBox = showScannerBox
        return view
    }
}
