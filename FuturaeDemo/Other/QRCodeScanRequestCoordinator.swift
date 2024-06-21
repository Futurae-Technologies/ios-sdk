//
//  QRCodeScanRequestCoordinator.swift
//  FuturaeDemo
//
//  Created by Valerii on 15.01.2024.
//  Copyright © 2024 Futurae. All rights reserved.
//

import Foundation

/**
 This is a drop-in implementation of push notification routing.
 It's a responsibility of the host app to implement push notification handling (possibly integrate with the existing flows).
 
 There are better ways to do it, this is just a sample.
 */
class QRCodeScanRequestCoordinator {
    static let instance = QRCodeScanRequestCoordinator()
    
    private var shouldNotifyScanQRCode = false
    
    private weak var delegate: QRCodeScanRequestDelegate?
    
    func notifyShouldScanQRCode() {
        if let delegate = delegate {
            shouldNotifyScanQRCode = false
            delegate.qrCodeScanRequested()
            return
        }
        
        shouldNotifyScanQRCode = true
    }
    
    func subscribeToQREvent(_ delegate: QRCodeScanRequestDelegate) {
        self.delegate = delegate
        
        if shouldNotifyScanQRCode {
            shouldNotifyScanQRCode = false
            delegate.qrCodeScanRequested()
        }
    }
}

protocol QRCodeScanRequestDelegate: AnyObject {
    func qrCodeScanRequested()
}
