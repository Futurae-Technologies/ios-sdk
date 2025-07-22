//
//  UIViewController+.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title:String, message:String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func promptForBindingToken(callback: @escaping (String?) -> Void) {
        let ac = UIAlertController(title: "Optional flow binding token", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            if UIPasteboard.general.string?.starts(with: "ey") == true {
                textField.text = UIPasteboard.general.string
            }
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            callback(answer.text)
        }

        ac.addAction(submitAction)

        dismiss(animated: false) {
            self.present(ac, animated: false, completion: nil)
        }
    }
}
