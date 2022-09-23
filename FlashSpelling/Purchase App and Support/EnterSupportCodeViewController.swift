//
//  EnterSupportCodeViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/21/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class EnterSupportCodeViewController: UIViewController {

    @IBOutlet weak var textFieldOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textFieldOutlet.becomeFirstResponder()
    }
    
    @IBAction func submitCodePressed(_ sender: UIButton) {
        codeEntered(code: textFieldOutlet.text!)
    }
    
    
    @IBAction func enterButtonPressed(_ sender: UITextField) {
        codeEntered(code: textFieldOutlet.text!)
    }
    
    func codeEntered(code: String) {
        let validatedCode = code.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let extensionDays = codeDictionary[validatedCode] {
            if extensionDays == -1 { // give app for free
                UserDefaults.standard.set(true, forKey: "fullAppPurchased")
                let alert = UIAlertController(title: "Success", message: "The full app has been unlocked", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(action) in
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                
            } else { // extend free trial
                UserDefaults.standard.set(extensionDays, forKey: "freeTrialPeriod")
                UserDefaults.standard.set(Date().toString(), forKey: "activationDate")
                
                let kvStorage: NSUbiquitousKeyValueStore! = NSUbiquitousKeyValueStore()
                kvStorage.set(Date().toString(), forKey: "activationDate")
                kvStorage.synchronize()

                let alert = UIAlertController(title: "Success", message: "Free trial has been extended by \(extensionDays) days", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(action) in
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil) // present alert
            }

        } else {
            let alert = UIAlertController(title: "Invalid Code", message: "The code \(validatedCode) is invalid. Please enter the 8 character code from support.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil) // present alert
        }
        
    }
    
    
    // [code: free month extension]
    var codeDictionary: [String: Int] = [
        "12345678": 30 // git hub only, not a live code

    ]

    
}
