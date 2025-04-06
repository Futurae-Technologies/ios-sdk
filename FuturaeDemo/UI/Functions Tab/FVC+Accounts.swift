//
//  FVC+Accounts.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

extension FunctionsViewController {
    @IBAction func logoutTouchedUpInside(_ sender: UIButton) {
        do {
            guard let account = try FTRClient.shared.getAccounts().first else {
                showAlert(title: "Error", message: "No user enrolled")
                return
            }

            FTRClient.shared.logoutAccount(account, success: {
                self.showAlert(title: "Success", message: "Logged out user \(account.username ?? "Username N/A")")
            }, failure: { error in
                self.showAlert(title: "Error", message: error.localizedDescription)
            })
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @IBAction func forceDeleteAccountTouchedUpInside(_ sender: UIButton) {
        do {
            guard let account = try FTRClient.shared.getAccounts().first else {
                showAlert(title: "Error", message: "No user enrolled")
                return
            }

            try FTRClient.shared.deleteAccount(account)
            showAlert(title: "Success", message: "Deleted user_id \(account.userId)")
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func fetchAccountHistory(_ sender: UIButton) {
        do {
            guard let account = try FTRClient.shared.getAccounts().first else { 
                self.showAlert(title: "Error", message: "No accounts available.")
                return
            }
            
            FTRClient.shared.getAccountHistory(account, success: { [weak self] responseObject in
                guard let self = self else { return }
                let allItems =  responseObject.activity.map { HistoryItem.init(activity: $0) }
                let vc = HistoryTableViewController(account: account, items: allItems)
                let nc = UINavigationController(rootViewController: vc)
                self.present(nc, animated: true, completion: nil)
            }, failure: { [weak self] error in
                let title = "Fetch account history failed"
                let message = error.localizedDescription
                self?.showAlert(title: title, message: message)
            })
        } catch {
            print(error)
        }
    }

    @IBAction func getAccountsStatus(_ sender: UIButton) {
        do {
            let accounts = try FTRClient.shared.getAccounts()
            FTRClient.shared.getAccountsStatus(accounts, success: { [weak self] responseObject in
                self?.showAlert(title: "Accounts status", message: "\(String(describing: responseObject.toDictionary()))")
            }, failure: { [weak self] error in
                let title = "Error"
                let message = error.localizedDescription
                self?.showAlert(title: title, message: message)
            })
        } catch {
            print(error)
        }
    }
    
    @IBAction func getAccountsStatusOffline(_ sender: UIButton) {
        do {
            let accounts = try FTRClient.shared.getAccounts()
            let accountsInfo = accounts.reduce("") { result, account in
                result + createAccountDescription(account)
            }

            showAlert(title: "Offline accounts status", message: accountsInfo)
        } catch {
            print(error)
        }
    }

    func createAccountDescription(_ account: FTRAccount) -> String {
        var dateString = ""
        
        if let date = account.enrolledAt {
            // Create another DateFormatter for converting to local time
            let localDateFormatter = DateFormatter()
            localDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            localDateFormatter.timeZone = TimeZone.current
            
            // Convert the Date object to a string in local time
            let localDateString = localDateFormatter.string(from: date)
            dateString = localDateString
            print("Local Time: \(localDateString)")
        } else {
            print("Failed to parse date.")
        }
        
        var info = "userid: \(account.userId)\n"
        info += "usename: \(account.username ?? "N/A")\n"
        info += "service name: \(account.serviceName ?? "N/A")\n"
        info += "locked_out: \(account.lockedOut ? "YES" : "NO")\n"
        info += "enrolled: \(account.enrolled ? "YES" : "NO")\n"
        info += "enrolled at: \(dateString)\n"
        return info
    }
    
    @IBAction func getActiveSessions(_ sender: UIButton) {
        do {
            let accounts = try FTRClient.shared.getAccounts()
            FTRClient.shared.getAccountsStatus(accounts, success: { [weak self] responseObject in
                let ac = UIAlertController(title: "Active sessions", message: "Select a session id", preferredStyle: .actionSheet)
                
                let sessions = responseObject.accounts.compactMap { $0.sessions }.joined()

                for session in sessions {
                    guard let sessionId = session.sessionId, let userId = session.userId else {
                        continue
                    }
                    
                    ac.addAction(UIAlertAction(title: session.sessionId ?? "No session id", style: .default, handler: { _ in
                        self?.dismiss(animated: true) {
                            FTRClient.shared.sessionInfo(.with(id: sessionId, userId: userId)) { [weak self] session in
                                FTRClient.shared.replyAuth(.approvePush(sessionId, userId: userId, extraInfo: session.extraInfo)) {
                                    self?.showAlert(title: "Success", message: "User authenticated successfully!")
                                } failure: { error in
                                    let title = "Error"
                                    let message = error.localizedDescription
                                    self?.showAlert(title: title, message: message)
                                }
                            } failure: { error in
                                let title = "Error"
                                let message = error.localizedDescription
                                self?.showAlert(title: title, message: message)
                            }
                        }
                    }))
                }

                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self?.dismiss(animated: true) {
                    self?.present(ac, animated: true, completion: nil)
                }
            }, failure: { [weak self] error in
                let title = "Error"
                let message = error.localizedDescription
                self?.showAlert(title: title, message: message)
            })
        } catch {
            print(error)
        }
    }
}
