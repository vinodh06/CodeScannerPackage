//
//  CodeScannerViewController.swift
//
//
//  Created by vinodh kumar on 11/04/23.
//

import UIKit
import AVFoundation
import SwiftUI

protocol CodeScanable {
    func sessionStarted()
}

public class CodeScannerViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var codeScannerDelegate: CodeScanable
    var metadataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero
    var maskBorderColor = UIColor.white
    var animationDuration: Double = 0.5
    var isScannerSupported = false
    var showScannerBox = true
    var failureAlertTexts: FailureAlertText
    public var isSessionStarted = false


    private var maskContainer: CGRect {
        CGRect(x: (view.bounds.width / 2) - (boundingBoxSize.width / 2),
               y: (view.bounds.height / 2) - (boundingBoxSize.height / 2),
               width: boundingBoxSize.width,
               height: boundingBoxSize.height)
    }

    private var scannerBoxView: CodeScannerBoxView?

    init(
        failureAlertTexts: FailureAlertText,
        delegate: AVCaptureMetadataOutputObjectsDelegate? = nil,
        codeScannerDelegate: CodeScanable
    ) {
        self.failureAlertTexts = failureAlertTexts
        self.delegate = delegate
        self.codeScannerDelegate = codeScannerDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidStartRunning), name: .AVCaptureSessionDidStartRunning, object: captureSession)
    }

    @objc
    func sessionDidStartRunning(notification: NSNotification) {
        isSessionStarted = true
        codeScannerDelegate.sessionStarted()
    }

    func scanningNotSupportedError() {
        isScannerSupported = false
        let alertController = UIAlertController(
            title: self.failureAlertTexts.title,
            message: self.failureAlertTexts.description,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: Constants.cameraFailureButtonTitle(),
                style: .default
            ) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )

        present(alertController, animated: true)
        captureSession = nil
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupScanner()
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    public override var prefersStatusBarHidden: Bool {
        true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    public override func viewDidLayoutSubviews() {
        if isScannerSupported {
            setupScanner()
            if showScannerBox && isSessionStarted {
                setupScannerBoundingBox()
            }
        }

        super.viewDidLayoutSubviews()
    }

    func setupScanner() {

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scanningNotSupportedError()
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scanningNotSupportedError()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scanningNotSupportedError()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataObjectTypes
        } else {
            scanningNotSupportedError()
            return
        }

        isScannerSupported = true

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start video capture.
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func setupScannerBoundingBox() {
        scannerBoxView?.layer.removeAllAnimations()
        scannerBoxView?.layer.removeFromSuperlayer()
        scannerBoxView = CodeScannerBoxView(
            frame: view.layer.bounds,
            lineWidth: 2,
            lineColor: maskBorderColor,
            maskSize: boundingBoxSize,
            animationDuration: animationDuration
        )
        view.addSubview(scannerBoxView!)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { [weak self] _ in
            // called right after rotation transition ends
            self?.view.setNeedsLayout()
        })
    }
}

public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    @Binding var scanResult: String?
    @Binding var isSessionStarted: Bool?
    var metadataObjectTypes: [AVMetadataObject.ObjectType]

    public init(metadataObjectTypes:  [AVMetadataObject.ObjectType] = [.ean8, .ean13], scanResult: Binding<String?>, isSessionStarted: Binding<Bool?>) {
        self.metadataObjectTypes = metadataObjectTypes
        self._scanResult = scanResult
        self._isSessionStarted = isSessionStarted
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scanResult = nil
            return
        }
        // Get the metadata object.
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
           metadataObjectTypes.contains(metadataObj.type),
           let result = metadataObj.stringValue {
            scanResult = result
        }
    }
}

extension Coordinator: CodeScanable {
    func sessionStarted() {
        isSessionStarted = true
    }
}


