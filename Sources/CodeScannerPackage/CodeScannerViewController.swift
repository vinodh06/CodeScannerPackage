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
    func cameraNotSupported()
    func hasNoCameraAccess()
}

public class CodeScannerViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var codeScannerDelegate: CodeScanable
    var metadataObjectTypes: [AVMetadataObject.ObjectType]  = []
    var isScannerSupported                                  = false
    public var isSessionStarted                             = false

    init(
        delegate: AVCaptureMetadataOutputObjectsDelegate? = nil,
        codeScannerDelegate: CodeScanable
    ) {
        self.delegate               = delegate
        self.codeScannerDelegate    = codeScannerDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionDidStartRunning),
            name: .AVCaptureSessionDidStartRunning,
            object: captureSession
        )
    }

    @objc
    func sessionDidStartRunning(notification: NSNotification) {
        isSessionStarted = true
        codeScannerDelegate.sessionStarted()
    }

    func scanningNotSupportedError() {
        isScannerSupported = false
        self.codeScannerDelegate.cameraNotSupported()
        captureSession = nil
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            checkCameraAccess()
            if captureSession?.isRunning == false {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        } else {
            scanningNotSupportedError()
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
            checkCameraAccess()
        }
        super.viewDidLayoutSubviews()
    }

    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            self.codeScannerDelegate.hasNoCameraAccess()
        case .restricted:
            self.codeScannerDelegate.hasNoCameraAccess()
        case .authorized:
            setupScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
                if success {
                    self?.setupScanner()
                } else {
                    self?.codeScannerDelegate.hasNoCameraAccess()
                }
            }
        @unknown default:
            self.codeScannerDelegate.hasNoCameraAccess()
        }
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
    @Binding var isSessionStarted: Bool
    @Binding var isCameraSupported: Bool
    @Binding var hasCameraAccess: Bool
    var metadataObjectTypes: [AVMetadataObject.ObjectType]

    public init(
        metadataObjectTypes:  [AVMetadataObject.ObjectType] = [.ean8, .ean13],
        scanResult: Binding<String?>,
        isSessionStarted: Binding<Bool>,
        isCameraSupported: Binding<Bool>,
        hasCameraAccess: Binding<Bool>
    ) {
        self.metadataObjectTypes    = metadataObjectTypes
        self._scanResult            = scanResult
        self._isSessionStarted      = isSessionStarted
        self._isCameraSupported     = isCameraSupported
        self._hasCameraAccess       = hasCameraAccess
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
           let result   = metadataObj.stringValue {
            scanResult  = result
        }
    }
}

extension Coordinator: CodeScanable {

    func sessionStarted() {
        isSessionStarted = true
    }

    func cameraNotSupported() {
        isCameraSupported = false
    }

    func hasNoCameraAccess() {
        hasCameraAccess = false
    }
}
