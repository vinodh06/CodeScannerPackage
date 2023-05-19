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
    var boundingBoxSize: CGSize     = .zero
    var maskBorderColor: UIColor    = UIColor.white
    var animationDuration: Double   = 0.5
    var showScannerBox: Bool        = true

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
        uiViewController.boundingBoxSize        = boundingBoxSize
        uiViewController.maskBorderColor        = maskBorderColor
        uiViewController.animationDuration      = animationDuration
        uiViewController.showScannerBox         = showScannerBox
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

    public func boundingBoxSize(_ size: CGSize) -> CodeScanner {
        var view                = self
        view.boundingBoxSize    = size
        return view
    }

    public func maskBorderColor(_ color: Color) -> CodeScanner {
        var view                = self
        view.maskBorderColor    = UIColor(color)
        return view
    }

    public func animationDuration(_ duration: Double) -> CodeScanner {
        var view                = self
        view.animationDuration  = duration
        return view
    }

    public func showScannerBox(_ isShow: Bool) -> CodeScanner {
        var view            = self
        view.showScannerBox = isShow
        return view
    }
}
