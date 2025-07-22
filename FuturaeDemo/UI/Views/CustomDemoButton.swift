//
//  CustomDemoButton.swift
//  FuturaeDemo
//
//  Created by Ruben Dudek on 29/06/2022.
//  Copyright © 2022 Futurae. All rights reserved.
//

import UIKit

@IBDesignable final class CustomDemoButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
       didSet {
           layer.cornerRadius = cornerRadius
           layer.masksToBounds = cornerRadius > 0
       }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
       didSet {
           layer.borderWidth = borderWidth
       }
    }
    @IBInspectable var borderColor: UIColor? {
       didSet {
           layer.borderColor = borderColor?.cgColor
       }
    }
}

