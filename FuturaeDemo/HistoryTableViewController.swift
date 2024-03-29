//
//  HistoryTableViewController.swift
//  FuturaeDemo
//
//  Created by Ruben Dudek on 16/01/2023.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit

@objc
public final class HistoryTableViewController: UITableViewController {
    
    private let account: FTRAccount
    private let items: [HistoryItem]
    
    @objc
    public init(account: FTRAccount, items: [HistoryItem]) {
        self.account = account
        self.items = items
        super.init(style: .plain)
        title = "Account: \(account.username ?? "")"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier) as? HistoryCell else {
            return UITableViewCell()
        }
        cell.successLabel.text = "Success: \(items[indexPath.row].success)"
        cell.titleLabel.text = "Type: \(items[indexPath.row].title)"
        cell.dateLabel.text = "Date: \(items[indexPath.row].date)"
        cell.resultLabel.text = "Result: \(items[indexPath.row].result)"
        return cell
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int { 1 }
}
