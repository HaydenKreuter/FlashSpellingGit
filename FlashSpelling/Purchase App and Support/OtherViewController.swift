//
//  OtherViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 7/25/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import StoreKit

class OtherViewController: UIViewController, MFMailComposeViewControllerDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var stackViewOutlet: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        if !UserDefaults.standard.bool(forKey: "fullAppPurchased") {
            let button = defaultButton()
            button.backgroundColor = UIColor.theme.grey
            button.setTitle("Purchase App", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(purchaseAppPressed), for: .touchUpInside)
            stackViewOutlet.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    @IBAction func leaveAReviewPressed(_ sender: UIButton) {
        let url = URL(string: "itms-apps://itunes.apple.com/app/" + "1639961476")!
        UIApplication.shared.open(url)
    }
    
    @IBAction func reportAnIssuePressed(_ sender: UIButton) {
        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScYrfFsTqUYMgPPtjW6sQ6v0XYK1LUJx1sGtuoxdkRR1MmP0Q/viewform?usp=sf_link") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func emailUsPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["FlashSpellingSchool@gmail.com"])
            mail.setSubject("Support ID: \(UUID())")
            
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Get help or send feedback", message: "Please contact: FlashSpellingSchool@gmail.com", preferredStyle: .alert)
            
            // adds an action to dismiss the alert
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil) // present alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    @IBAction func restorePurchasePressed(_ sender: UIButton) {
        if (SKPaymentQueue.canMakePayments()) {
          SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            let alert = UIAlertController(
                title: "Unable to restore purchase",
                message: "",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            navigationController?.popToRootViewController(animated: true)
            
            self.present(alert, animated: true)
        }
        
    }
    
    @objc func purchaseAppPressed(sender: UIButton) {
        let kvStorage: NSUbiquitousKeyValueStore! = NSUbiquitousKeyValueStore()
        var checkedStartDate: Date!
        let dateFromCloudKit: Date? = kvStorage.string(forKey: "activationDate")?.toDate()
        let dateFromDefaults: Date? = UserDefaults.standard.string(forKey: "activationDate")?.toDate()

        
        var freeTrialPeriod: Int = 30
        let freeTrialUserDefaults = UserDefaults.standard.integer(forKey: "freeTrialPeriod")
        if freeTrialUserDefaults > 0 {
            freeTrialPeriod = freeTrialUserDefaults
        }
        
        if dateFromCloudKit != nil {
            if dateFromDefaults != nil {
                if dateFromCloudKit! < dateFromDefaults! {
                    checkedStartDate = dateFromCloudKit!
                } else {
                    checkedStartDate = dateFromDefaults!
                }
            } else {
                checkedStartDate = dateFromCloudKit!
            }
        } else if dateFromDefaults != nil {
            checkedStartDate = dateFromDefaults!
        } else {
            checkedStartDate = Date()
        }
        let timePassed = Date().timeIntervalSince(checkedStartDate)
        let daysPassed = timePassed / 86400
        let alert = UIAlertController(
            title: "Purchase App for $1.99",
            message: "You still have \(freeTrialPeriod - Int(daysPassed)) days left in your free trial to use that app for free. Would you like to purchase the app early for $1.99?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        alert.addAction(UIAlertAction(title: "Purchase App", style: .default, handler: { action in
            if SKPaymentQueue.canMakePayments() {
                let purchaseID = "FullApp"
                let transactionRequest = SKMutablePayment()
                transactionRequest.productIdentifier = purchaseID
                SKPaymentQueue.default().add(transactionRequest)
            } else {
                let alert = UIAlertController(
                    title: "Unable to complete payment",
                    message: "Please try again later",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                
                self.present(alert, animated: true)
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased || transaction.transactionState == .restored {
                UserDefaults.standard.set(true, forKey: "fullAppPurchased")
                let alert = UIAlertController(
                    title: "Success!",
                    message: "",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                
                self.present(alert, animated: true)
                
            } else if transaction.transactionState == .failed {
                let alert = UIAlertController(
                    title: "Unable to restore purchase!",
                    message: "",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    
    
}
