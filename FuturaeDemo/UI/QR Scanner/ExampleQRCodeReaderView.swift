//
//  ExampleQRCodeReaderView.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 6.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import UIKit

class ExampleQRCodeReaderView: UIView {

    var overlay: CAShapeLayer!

    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addOverlay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Overrides
    override func draw(_ rect: CGRect) {
        var innerRect = rect.insetBy(dx: 50, dy: 50)
        
        let minSize = min(innerRect.size.width, innerRect.size.height)
        if innerRect.size.width != minSize {
            innerRect.origin.x += (innerRect.size.width - minSize) / 2
            innerRect.size.width = minSize + fmod(minSize, 2)
            innerRect.size.height = minSize
        } else if innerRect.size.height != minSize {
            innerRect.origin.y += (innerRect.size.height - minSize) / 2
            innerRect.size.height = minSize + fmod(minSize, 2)
            innerRect.size.width = minSize
        }
        
        let offsetRect = innerRect.offsetBy(dx: 0, dy: 15)
        
        let cornerWidth = NSNumber(value: 50.0)
        let cornerSpace = NSNumber(value: offsetRect.size.width - 100.0)
        
        overlay.lineDashPattern = [cornerWidth, cornerSpace,
                                   cornerWidth, 0,
                                   cornerWidth, cornerSpace,
                                   cornerWidth, 0,
                                   cornerWidth, cornerSpace,
                                   cornerWidth, 0,
                                   cornerWidth, cornerSpace,
                                   cornerWidth]
        
        overlay.path = UIBezierPath(rect: offsetRect).cgPath
    }

    // method
    func addOverlay() {
        overlay = CAShapeLayer()
        overlay.backgroundColor = UIColor.clear.cgColor
        overlay.fillColor = UIColor.clear.cgColor
        overlay.strokeColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        overlay.lineWidth = 6
        overlay.lineCap = .square
        
        layer.addSublayer(overlay)
    }
}
