//
//  AdaptiveViewController.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 26.1.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit

class AdaptiveViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var collections: [[String: Any]] = []
    var pendingCollections: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collections = AdaptiveDebugStorage.shared().savedCollections().sorted(by: {
            if let timestamp1 = $0["timestamp"] as? Double, let timestamp2 = $1["timestamp"] as? Double {
                return timestamp1 > timestamp2
            }
            
            return true
        })
        pendingCollections = FTRClient.shared()?.pendingAdaptiveCollections() ?? []
        tableView.reloadData()
    }
    
    @IBAction func closeTextView(_ sender: Any) {
        textView.isHidden = true
        closeButton.isHidden = true
    }

}

extension AdaptiveViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdaptiveCell") as! AdaptiveTableViewCell
        if let timestamp = collections[indexPath.row]["timestamp"] as? Double {
            let date = Date(timeIntervalSince1970: timestamp).description
            var status = "UPLOADED"
            if let _ = (pendingCollections.first { $0["timestamp"] as? Double == timestamp }) {
                status = "PENDING"
            }
            
            cell.titleLabel.text = "\(date) : \(status) "
        }
        
        return cell
    }
}

extension AdaptiveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]
        if let data = try? JSONSerialization.data(withJSONObject: collection, options: .prettyPrinted) {
            textView.text = String(data: data, encoding: .utf8)
            textView.isHidden = false
            closeButton.isHidden = false
        }
    }
}
