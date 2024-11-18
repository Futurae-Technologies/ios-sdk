//
//  ExampleQRCodeReaderView.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 6.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit
import AVFoundation
import FuturaeKit

enum QRCodeType: UInt {
    case enrollment
    case onlineAuth
    case offlineAuth
    case generic
}

protocol ExampleQRCodeReaderDelegate: AnyObject {
    func reader(_ reader: ExampleQRCodeViewController, didScanResult result: String?)
    func readerDidCancel(_ reader: ExampleQRCodeViewController)
}

class ExampleQRCodeViewController: UIViewController {

    var delegate: ExampleQRCodeReaderDelegate!
    var cameraView: ExampleQRCodeReaderView!
    
    var codeReader: FTRQRCodeReader!
    var QRCodeType: QRCodeType

    init(title: String, QRCodeType: QRCodeType) {
        self.QRCodeType = QRCodeType
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        codeReader = FTRQRCodeReader()
        setup()

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .gray
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        codeReader.previewLayer.frame = view.bounds
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func startScanning() {
        codeReader.startScanning()
    }

    func stopScanning() {
        codeReader.stopScanning()
    }

    func setup() {
        setupUIComponents()
        setupAutoLayoutConstraints()

        cameraView.layer.insertSublayer(codeReader.previewLayer, at: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        codeReader.setCompletionWithBlock { [unowned self] resultAsString in
            delegate.reader(self, didScanResult: resultAsString)
        }
        
//        codeReader.setCompletionWith { [unowned self] resultAsString in
//            delegate.reader(self, didScanResult: resultAsString)
//        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closedPressed))
    }

    func setupUIComponents() {
        cameraView = ExampleQRCodeReaderView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.clipsToBounds = true
        view.addSubview(cameraView!)

        codeReader.previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

        if codeReader.previewLayer.connection?.isVideoOrientationSupported ?? false {
            let orientation = UIApplication.shared.statusBarOrientation
//            codeReader.previewLayer.connection?.videoOrientation = FTRQRCodeReader.videoOrientation(from: orientation)
            
            codeReader.previewLayer.connection?.videoOrientation = FTRQRCodeReader.videoOrientationFromInterfaceOrientation(orientation)
        }
    }

    func setupAutoLayoutConstraints() {
        guard let cameraView = cameraView else { return }
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func orientationChanged(_ notification: Notification) {
        cameraView.setNeedsDisplay()

        if codeReader.previewLayer.connection?.isVideoOrientationSupported ?? false {
            let orientation = UIApplication.shared.statusBarOrientation
            codeReader.previewLayer.connection?.videoOrientation = FTRQRCodeReader.videoOrientationFromInterfaceOrientation(orientation)
        }
    }

    @objc func closedPressed() {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        stopScanning()
        NotificationCenter.default.removeObserver(self)
    }
}
