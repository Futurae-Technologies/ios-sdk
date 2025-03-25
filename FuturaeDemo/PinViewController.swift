//
//  PinViewController.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 31/10/17.
//  Copyright © 2017 Xornorik. All rights reserved.
//
import UIKit

public enum PinMode: String {
    case set
    case update
    case input
    case shortCode
}

public class PinViewController: UIViewController {
    public static func create(pinMode: PinMode, title: String, pinCompletionHandler: ((String?) -> Void)? = nil) -> PinViewController{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as! PinViewController
        vc.pinMode = pinMode
        vc.title = title
        vc.didFinishWithPin = pinCompletionHandler
        return vc
    }
    
    @IBOutlet var pinView: SVPinView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    public var didFinishWithPin: ((String?) -> Void)?
    public var pinMode: PinMode!
    var pinLength = 4
    var secureText = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configurePinView()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Setup background gradient
        let valenciaColor = UIColor.black.withAlphaComponent(1)
        let discoColor = UIColor.black.withAlphaComponent(1)
        setGradientBackground(view: self.view, colorTop: valenciaColor, colorBottom: discoColor)
    }
    
    @objc public func setPinMode(_ mode: String){
        pinMode = PinMode(rawValue: mode)
    }
    
    @objc public func setPinLength(_ length: Int){
        pinLength = length
    }
    
    @objc public func setSecureText(_ secure: Bool){
        secureText = secure
    }
    
    @objc public func setDidFinishWithPin(callback: ((String?) -> Void)?){
        didFinishWithPin = callback
    }
    
    func configurePinView() {
        if pinMode == .shortCode {
            titleLabel.text = "Manual Entry Enroll Code"
            subtitleLabel.isHidden = true
        } else {
            titleLabel.text = title
        }
        
        pinView.pinLength = pinLength
        
        if secureText {
            pinView.placeholder = "******"
            pinView.secureCharacter = "\u{25CF}"
            pinView.allowsWhitespaces = false
            pinView.keyboardType = .phonePad
            pinView.style = .none
            
            pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
            pinView.activeFieldBackgroundColor = UIColor.white.withAlphaComponent(0.5)
            pinView.fieldCornerRadius = 15
            pinView.activeFieldCornerRadius = 15
            pinView.interSpace = 10
        } else {
            pinView.keyboardType = .default
            pinView.allowsWhitespaces = true
            pinView.style = .underline
            pinView.secureCharacter = ""
            pinView.interSpace = 3
        }
        
        pinView.shouldSecureText = secureText
        
        
        pinView.textColor = UIColor.white
        pinView.borderLineColor = UIColor.white
        pinView.activeBorderLineColor = UIColor.white
        pinView.borderLineThickness = 1

        pinView.deleteButtonAction = .deleteCurrentAndMoveToPrevious
        pinView.keyboardAppearance = .default
        pinView.tintColor = .white
        pinView.becomeFirstResponderAtIndex = 0
        pinView.shouldDismissKeyboardOnEmptyFirstField = false
        
        pinView.font = UIFont.systemFont(ofSize: 15)
        
        pinView.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        pinView.didFinishCallback = didFinishEnteringPin(pin:)
        pinView.didChangeCallback = { pin in
            print("The entered pin is \(pin)") 
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    
    @IBAction func clearPin() {
        pinView.clearPin()
    }
    
    @IBAction func pastePin() {
        guard let pin = UIPasteboard.general.string else {
            showAlert(title: "Error", message: "Clipboard is empty")
            return
        }
        pinView.pastePin(pin: pin)
    }
    
    func didFinishEnteringPin(pin:String) {
        dismiss(animated: true)
        
        let callback = didFinishWithPin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            callback?(pin)
        }
    }
    
    func setGradientBackground(view:UIView, colorTop:UIColor, colorBottom:UIColor) {
        for layer in view.layer.sublayers! {
            if layer.name == "gradientLayer" {
                layer.removeFromSuperlayer()
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.name = "gradientLayer"
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIViewController {
    // MARK: Helper Functions
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
