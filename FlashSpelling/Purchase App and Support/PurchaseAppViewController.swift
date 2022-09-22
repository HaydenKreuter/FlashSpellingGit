//
//  PurchaseAppViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/17/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseAppViewController: UIViewController, SKPaymentTransactionObserver {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
     
    }
    

    @IBAction func unlockFullAppPressed(_ sender: UIButton) {
        
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
        
    }
    
    @IBAction func restorePurchase(_ sender: UIButton) {
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
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased || transaction.transactionState == .restored {
                UserDefaults.standard.set(true, forKey: "fullAppPurchased")
                let alert = UIAlertController(
                    title: "Success!",
                    message: "",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Return to menu", style: .cancel))
                navigationController?.popToRootViewController(animated: true)
                
                self.present(alert, animated: true)
                
            } else if transaction.transactionState == .failed {
                let alert = UIAlertController(
                    title: "Purchase failed, please try again",
                    message: "",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                
                self.present(alert, animated: true)
            }
        }
    }

}
