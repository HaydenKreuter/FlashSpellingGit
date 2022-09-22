//
//  createSpellingListViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/13/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit
import UserNotifications

class CreateSpellingListViewController: UIViewController {
    
    var editingList: WordList? // passed from SpellingListViewController
    
    // MARK: - UI Element Outlets
    @IBOutlet weak var navigationBarOutlet: UINavigationItem!
    @IBOutlet weak var listTitleTextFieldOutlet: UITextField!
    @IBOutlet weak var testDateSwitchOutlet: UISwitch!
    @IBOutlet weak var backgroundViewOutlet: UIView!
    @IBOutlet weak var testDatePickerOutlet: UIDatePicker!
    
    var addWordsVC: AddWordsViewController!
    var tutorialIsPresented: Bool = false
    
    // MARK: - UI Button Actions/ Events

    
    @IBAction func addTestDateChanged(_ sender: UISwitch) {
        if testDateSwitchOutlet.isOn {
            testDatePickerOutlet.isHidden = false
        } else {
            testDatePickerOutlet.isHidden = true
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Are you sure you want to go back?",
            message: "Any new progress will not be saved",
            preferredStyle: .alert)
        let goBack = UIAlertAction(title: "Go Back", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(UIAlertAction(title: "Continue Working", style: .cancel))
        alert.addAction(goBack)
        
        self.present(alert, animated: true)
        
        
    }

    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        testDatePickerOutlet.minimumDate = Date()
        testDatePickerOutlet.maximumDate = Date().addingTimeInterval(100000000)
        testDatePickerOutlet.tintColor = .blue
        
        backgroundViewOutlet.layer.cornerRadius = 7
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "addWordsVC") as! AddWordsViewController
        addWordsVC = newViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let list = editingList {
            navigationBarOutlet.title = "Edit List"
            listTitleTextFieldOutlet.text = list.name
            
            if let testDate = list.testDate {
                testDateSwitchOutlet.isOn = true
                testDatePickerOutlet.date = testDate
                testDatePickerOutlet.isHidden = false
            } else {
                testDateSwitchOutlet.isOn = false
                testDatePickerOutlet.isHidden = true
            }
        } else {
            navigationBarOutlet.title = "Create a new list"
            testDatePickerOutlet.isHidden = true
            testDateSwitchOutlet.isOn = false
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        if !tutorialIsPresented {
            if testDateSwitchOutlet.isOn && !UserDefaults.standard.bool(forKey: "hasRequestedPermission") {
                var decisionTree: [treeItem] = []
                decisionTree.append(treeItem(textPages: ["I can send you study reminders to help you keep on track when studying for a test! Would you like to receive these notifications?"], options: [["Turn on", "No Thanks", "Maybe Later"]]))
                
                let tree = DecisionTreeView(frame: view.frame, decisionTree: decisionTree)
                view.addSubview(tree)
                tree.translatesAutoresizingMaskIntoConstraints = false
                tree.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                tree.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                tree.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                tree.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                tree.center.x = -tree.frame.width / 2
                tree.tutorialResponseDelegate = self
                listTitleTextFieldOutlet.resignFirstResponder()
                tutorialIsPresented = true
                UIView.animate(withDuration: 1) {
                    tree.center.x = tree.frame.width / 2
                }
                
            } else {
                self.navigationController?.pushViewController(addWordsVC, animated: true)
            }
            

            addWordsVC.listTitle = listTitleTextFieldOutlet.text?.trimmingCharacters(in: .whitespaces).capitalized
            if testDateSwitchOutlet.isOn {
                addWordsVC.testDate = testDatePickerOutlet.date
            }
            if let list = editingList {
                addWordsVC.editingList = list
            }
        }


    }
    
    // MARK: -

}


extension CreateSpellingListViewController: tutorialResponseDelegate {
    func selectedOption(optionIndex: Int) {
        if optionIndex == 0 { // turn on notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { [self] granted, _ in
                DispatchQueue.main.async { [self] in
                    UserDefaults.standard.set(true, forKey: "hasRequestedPermission")
                    tutorialIsPresented = false
                    self.navigationController?.pushViewController(self.addWordsVC, animated: true)
                }
                
              }
        } else if optionIndex == 1 {
            self.navigationController?.pushViewController(addWordsVC, animated: true)
            tutorialIsPresented = false
            UserDefaults.standard.set(true, forKey: "hasRequestedPermission")
        } else {
            tutorialIsPresented = false
            self.navigationController?.pushViewController(addWordsVC, animated: true)
        }
    }
    
}

