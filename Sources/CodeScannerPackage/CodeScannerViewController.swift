//
//  CodeScannerViewController.swift
//
//
//  Created by vinodh kumar on 11/04/23.
//

import UIKit
import AVFoundation
import SwiftUI

public class CodeScannerViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var metaDataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero
    var maskBorderColor = UIColor.white
    var animationDuration: Double = 0.5
    var isScannerSupported = true
    var isAnimateScanner = true

    private var maskContainer: CGRect {
        CGRect(x: (view.bounds.width / 2) - (boundingBoxSize.width / 2),
               y: (view.bounds.height / 2) - (boundingBoxSize.height / 2),
               width: boundingBoxSize.width,
               height: boundingBoxSize.height)
    }

    private var scannerBoundingBoxView: CodeScannerBoundingBoxView?

    public init(delegate: AVCaptureMetadataOutputObjectsDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    func scanningNotSupportedError() {
//        isScannerSupported = false
//        let alertController = UIAlertController(
//            title: Constants.cameraFailureTitle(),
//            message: Constants.cameraFailureDescription(),
//            preferredStyle: .alert
//        )
//        alertController.addAction(
//            UIAlertAction(
//                title: Constants.cameraFailureButtonTitle(),
//                style: .default
//            ) { [weak self] _ in
//                self?.dismiss(animated: true)
//            }
//        )
//
//        present(alertController, animated: true)
        captureSession = nil
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
            setupScannerBoundingBox()
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
            metadataOutput.metadataObjectTypes = metaDataObjectTypes
        } else {
            scanningNotSupportedError()
            return
        }

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
        scannerBoundingBoxView?.layer.removeAllAnimations()
        scannerBoundingBoxView?.layer.removeFromSuperlayer()
        scannerBoundingBoxView = CodeScannerBoundingBoxView(
            frame: view.layer.bounds,
            lineWidth: 2,
            lineColor: maskBorderColor,
            maskSize: boundingBoxSize,
            animationDuration: animationDuration,
            isAnimateScanner: isAnimateScanner
        )
        view.addSubview(scannerBoundingBoxView!)
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
    var metaDataObjectTypes: [AVMetadataObject.ObjectType] = []
    var boundingBoxSize: CGSize = .zero

    public init(_ scanResult: Binding<String?>) {
        self._scanResult = scanResult
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scanResult = nil
            return
        }
        // Get the metadata object.
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
           metaDataObjectTypes.contains(metadataObj.type),
           let result = metadataObj.stringValue {
            scanResult = result
        }
    }
}
