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

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metaDataObjectTypes
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start video capture.
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    @Binding var scanResult: String
    @Binding var isScanned: Bool
    var metaDataObjectTypes: [AVMetadataObject.ObjectType]

    public init(_ scanResult: Binding<String>, _ isScanned: Binding<Bool>, metaDataObjectTypes: [AVMetadataObject.ObjectType]) {
        self._scanResult = scanResult
        self._isScanned = isScanned
        self.metaDataObjectTypes = metaDataObjectTypes
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scanResult = ""
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if self.metaDataObjectTypes.contains(metadataObj.type), let result = metadataObj.stringValue {
            scanResult = result
            isScanned = true
        }
    }
}

