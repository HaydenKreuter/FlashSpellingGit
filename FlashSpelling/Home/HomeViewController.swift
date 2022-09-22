//
//  ViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/5/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var context: NSManagedObjectContext!
    var resultsList: [WordList] = []
    var linkOpenList: WordList? // used when opening a list from shared json
    
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var flashImageOutlet: UIImageView!
    // MARK: - Collection View Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        
        let item = resultsList[indexPath.item]
    
        cell.nameLabelOutlet.text = item.name
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let formatedDate = formatter.string(from: item.dateCreated)
        cell.dateCreatedLabel.text = "Created On: \(formatedDate)"
        
        // there has got to be a better way to do this
        if item.wordsArray.count > 0 {
            cell.word1.text = item.wordsArray[0].wordName
        } else {
            cell.word1.text = ""
        }
        
        if item.wordsArray.count > 1 {
            cell.word2.text = item.wordsArray[1].wordName
        } else {
            cell.word2.text = ""
        }
        if item.wordsArray.count > 2 {
            cell.word3.text = item.wordsArray[2].wordName
        } else {
            cell.word3.text = ""
        }
        if item.wordsArray.count > 3 {
            cell.word4.text = item.wordsArray[3].wordName
        } else {
            cell.word4.text = ""
        }
        if item.wordsArray.count > 4 {
            cell.word5.text = item.wordsArray[4].wordName
        } else {
            cell.word5.text = ""
        }
        if item.wordsArray.count > 5 {
            cell.word6.text = item.wordsArray[5].wordName
        } else {
            cell.word6.text = ""
        }
        if item.wordsArray.count > 6 {
            cell.word7.text = item.wordsArray[6].wordName
        } else {
            cell.word7.text = ""
        }

    
        if let testDate = item.testDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let formatedDate = formatter.string(from: testDate)
            cell.testDateLabel.text = "Test date: \(formatedDate)"
        } else {
            cell.testDateLabel.text = ""
        }
        return cell
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Home"
        // set up for core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context

    }
    
    @IBAction func leaveReviewPressed(_ sender: UIBarButtonItem) {
        let url = URL(string: "itms-apps://itunes.apple.com/app/" + "1639961476")!
        UIApplication.shared.open(url)
    }
    
    
    
    func openLinkedList(newList: WordListEntity) {
        refreshData()
        
        /*
        for list in resultsList {
            if list.entity == newList {
                linkOpenList = list
                performSegue(withIdentifier: "openLinkItem", sender: self)
            }
        }
         */
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func setCellLayout() {
        let aspectRatio: CGFloat = CGFloat(300.0 / 388.0)
        var height: CGFloat = collectionViewOutlet.frame.height - 30
        var width: CGFloat = height * aspectRatio
        if height > 600 {
            height = (height / 2) - 15
            width = height * aspectRatio
        }
        let cellSize = CGSize(width: width, height: height)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 35
        layout.minimumInteritemSpacing = 35
        collectionViewOutlet.setCollectionViewLayout(layout, animated: true)
        
    }
    
    func refreshData() {
        var spellingLists: [WordListEntity] = []
        resultsList = []
        let request: NSFetchRequest<WordListEntity> = WordListEntity.fetchRequest()
        if context != nil {
            do {
                spellingLists = try context.fetch(request)
            } catch {}
            
            for list in spellingLists {
                let words = (list.wordEntity!.allObjects as! [WordEntity]).sorted(by: { $0.order < $1.order })
                
                
                let newItem = WordList(name: list.listName, dateCreated: list.dateCreated, testDate: list.testDate, category: 0, entity: list, wordsArray: words)
                resultsList.append(newItem)
            }
            
            resultsList.sort { $0.dateCreated > $1.dateCreated }
            collectionViewOutlet.reloadData()
        }

    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshData()
        
        if !UserDefaults.standard.bool(forKey: "fullAppPurchased") {
            // cloud kit key value storage
            let kvStorage: NSUbiquitousKeyValueStore! = NSUbiquitousKeyValueStore()
            var checkedStartDate: Date!
            let dateFromCloudKit: Date? = kvStorage.string(forKey: "activationDate")?.toDate()
            let dateFromDefaults: Date? = UserDefaults.standard.string(forKey: "activationDate")?.toDate()
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
            
            kvStorage.set(checkedStartDate.toString(), forKey: "activationDate")
            kvStorage.synchronize()
            
            UserDefaults.standard.set(checkedStartDate.toString(), forKey: "activationDate")
            let timePassed = Date().timeIntervalSince(checkedStartDate)
           
            let daysPassed = timePassed / 86400
            
            var freeTrialPeriod: Int = 30
            let freeTrialUserDefaults = UserDefaults.standard.integer(forKey: "freeTrialPeriod")
            if freeTrialUserDefaults > 0 {
                freeTrialPeriod = freeTrialUserDefaults
            }
            
            if Int(daysPassed) > freeTrialPeriod { // free trial over
                performSegue(withIdentifier: "purchaseApp", sender: self)
            } else {
                navigationItem.title = "\(freeTrialPeriod - Int(daysPassed)) days left in free trial"
            }
        } else {
            navigationItem.title = "Flash Spelling"
        }
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setCellLayout()
        
        if UserDefaults.standard.bool(forKey: "introTutorial") == false {
            let tutorialView = TutorialView(frame: view.frame, pages: ["Hi there my name is Flash! I’m here to help you learn spelling fast! All you have to do is make a list of words you want to learn, and I will help you master them!", "You can study your word list, take practice tests, play interactive games, and monitor your progress all from the app!", "Included is a 30 day free trial so you can see if it's right for you. If you enjoy the app, the full version is available for $1.99, which  includes all content added in the future.", "Press the 'New Spelling List' button to make your first list! I can't wait to join you on your spelling journey!"])
            view.addSubview(tutorialView)
            tutorialView.translatesAutoresizingMaskIntoConstraints = false
            tutorialView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tutorialView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tutorialView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tutorialView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tutorialView.center.x = -tutorialView.frame.width / 2
            
            UIView.animate(withDuration: 1) {
                tutorialView.center.x = tutorialView.frame.width / 2
            }
            UserDefaults.standard.set(true, forKey: "introTutorial")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: .none) { [self] _ in
            setCellLayout()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openItem" {
            let controller = segue.destination as! SpellingListViewController
            if let indexPath = collectionViewOutlet.indexPathsForSelectedItems {
                let selectedItem = resultsList[indexPath[0].item]
                controller.selectedList = selectedItem
            }
        } else if segue.identifier == "openLinkItem" {
            let controller = segue.destination as! SpellingListViewController
            if linkOpenList != nil {
                let selectedItem = linkOpenList
                controller.selectedList = selectedItem
            }
        }
    }

}

// MARK: -
