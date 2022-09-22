//
//  MoreOptionsViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/17/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import MessageUI

class MoreOptionsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let kvStorage: NSUbiquitousKeyValueStore! = NSUbiquitousKeyValueStore()
        
        if kvStorage.bool(forKey: "usedAdditionalFreeTrial") == true || UserDefaults.standard.bool(forKey: "usedAdditionalFreeTrial") == true {
            freeTrialButtonOutlet.removeFromSuperview()
        }

    }
    @IBOutlet weak var freeTrialButtonOutlet: UIButton!
    
    @IBAction func expandFreeTrial(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "We're sorry the free trial did not give you enough time to try the app",
            message: "We'd like to offer you an extra week to try us out!",
            preferredStyle: .alert)
        let continueFreeTrial = UIAlertAction(title: "Extend Free Trial", style: .default) { _ in
            let kvStorage: NSUbiquitousKeyValueStore! = NSUbiquitousKeyValueStore()
            let date = Date().addingTimeInterval(-604800)
            kvStorage.set(date.toString(), forKey: "activationDate")
            UserDefaults.standard.set(date.toString(), forKey: "activationDate")
            
            UserDefaults.standard.set(true, forKey: "usedAdditionalFreeTrial")
            kvStorage.set(true, forKey: "usedAdditionalFreeTrial")
            
            kvStorage.synchronize()
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(continueFreeTrial)
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func unableToPay(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["FlashSpellingSchool@gmail.com"])
            mail.setSubject("Unable to pay. Please tell us what the issue is in the email below. Support ID: \(UUID())")
            
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Please let us know what the issue is by sending us an email", message: "Please contact: FlashSpellingSchool@gmail.com", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil) // present alert
        }
    }
    
    @IBAction func other(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["FlashSpellingSchool@gmail.com"])
            mail.setSubject("Please let us know what the issue in Support ID: \(UUID())")
            
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Please let us know what the issue is by sending us an email", message: "Please contact: FlashSpellingSchool@gmail.com", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil) // present alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
}
