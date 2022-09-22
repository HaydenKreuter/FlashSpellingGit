//
//  viewItemViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/18/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData

class SpellingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var context: NSManagedObjectContext!
    var selectedList: WordList!
    var words: [WordEntity] = []
    var startTest: Bool = false
    // MARK: - UI Element Outlets
    @IBOutlet weak var itemTableViewOutlet: UITableView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var topViewOutlet: UIView!
    @IBOutlet weak var circularViewOutelt: UIView!
    @IBOutlet weak var totalMasteryLabelOutlet: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewStudyProgressButtonOutlet: defaultButton!
    
    var dialogDisplaying = false
    
    
    var circularProgressBarView: CircularResultWheelView!
    var circularViewDuration: TimeInterval = 1
    var isBaselineTest = false
    var totalMastery: Double = 0
    
    // MARK: - Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spellingWordPreview") as! SpellingItemTableViewCell
        let wordItem = words[indexPath.item]
        cell.primaryLabelOutlet.text = wordItem.wordName!
        cell.countLabelOutlet.text = "\(indexPath.item + 1)"
   
        for i in 0...4 {
            let starMastery = wordItem.mastery - Double(20 * i)
            let imageView = cell.starStackOutlet.arrangedSubviews[i] as! UIImageView
            if starMastery >= 20 {
                
                if #available(iOS 13.0, *) {
                    imageView.image = UIImage(systemName: "star.fill")
                } else {
                    imageView.image = UIImage(named: "starFill")!.withRenderingMode(.alwaysTemplate)
                }
            } else if starMastery > 0 {
                if #available(iOS 13.0, *) {
                    imageView.image = UIImage(systemName: "star.leadinghalf.filled")
                } else {
                    imageView.image = UIImage(named: "starHalfFill")!.withRenderingMode(.alwaysTemplate)
                }
            } else {
                if #available(iOS 13.0, *) {
                    imageView.image = UIImage(systemName: "star")
                } else {
                    imageView.image = UIImage(named: "star")!.withRenderingMode(.alwaysTemplate)
                }
            }

        }
        return cell
    }
    
    // MARK: - UI Button Actions
    
    @IBAction func editItemPressed(_ sender: UIBarButtonItem) {

        if selectedList.entity.testInProgress == nil && selectedList.entity.wordSearchPuzzle == nil {
            performSegue(withIdentifier: "editList", sender: self)
        } else {
            let alert = UIAlertController(title: "Edit List?", message: "Are you sure you want to edit this list? The current test and games in progress will be deleted.", preferredStyle: .alert)


            let editListAction = UIAlertAction(title: "Edit List", style: .destructive, handler: { [self] _ in
                if let test = selectedList.entity.testInProgress {
                    context.delete(test)
                }
                if let wordSearch = selectedList.entity.wordSearchPuzzle {
                    context.delete(wordSearch)
                }
                
                
                do {
                    try context.save()
                } catch {
                    
                }
                performSegue(withIdentifier: "editList", sender: self)
                
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

    
            alert.addAction(editListAction)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete List", message: "Are you sure you want to delete this list? This action can not be undone?", preferredStyle: .alert)


        let deleteListAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
            
            for word in selectedList.entity.wordEntity! {
                let wordEntity = word as! WordEntity
                if wordEntity.recordingPath != "0" {
                    let file = getDirectory().appendingPathComponent(wordEntity.recordingPath!)
                    do {
                        try FileManager.default.removeItem(at: file)
                    } catch {
                        print("Could not delete file")
                    }
                }
                context.delete(wordEntity)
            }
            
            context.delete(selectedList.entity)
            
            do {
                try context.save()
            } catch {
                
            }
            
            navigationController?.popViewController(animated: true)
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(deleteListAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func setUpCircularProgressBarView(scoreRatio: Double) {
        // set view
        circularProgressBarView = CircularResultWheelView(frame: .zero, scoreRatio: scoreRatio , parentViewSize: topViewOutlet.frame.size)

        circularProgressBarView.createCircularPath()
        circularProgressBarView.alpha = 0
        // call the animation with circularViewDuration
        
        circularProgressBarView.progressAnimation(duration: circularViewDuration)
        // add this view to the view controller
        topViewOutlet.addSubview(circularProgressBarView)
        circularProgressBarView.translatesAutoresizingMaskIntoConstraints = false
 
        topViewOutlet.addConstraint(NSLayoutConstraint(item: circularProgressBarView!, attribute: .centerX, relatedBy: .equal, toItem: topViewOutlet, attribute: .centerX, multiplier: 1, constant: 0))
        topViewOutlet.addConstraint(NSLayoutConstraint(item: circularProgressBarView!, attribute: .centerY, relatedBy: .equal, toItem: topViewOutlet, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    @IBAction func shareListPressed(_ sender: UIBarButtonItem) {
        // presents activity controller to ask where to send
        let path = saveToTemporaryFile(myConcreteObjects: selectedList.entity)
        
        let activityController = UIActivityViewController(activityItems: [NSURL(fileURLWithPath: path)], applicationActivities: nil)
        activityController.excludedActivityTypes = [.message,.copyToPasteboard]
        activityController.popoverPresentationController?.barButtonItem = sender
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    
    func getDirectory() -> URL { // gets path to directory  to save audio recordings
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    
    func saveToTemporaryFile(myConcreteObjects: WordListEntity) -> String {
        let dictionaryObjects: [String: Any] = myConcreteObjects.toDictionary()

        let path = NSTemporaryDirectory() + "/" + NSUUID().uuidString + ".wordListData"

        let data: Data? = try? JSONSerialization.data(withJSONObject: dictionaryObjects, options: .prettyPrinted)
        try? data?.write(to: URL(fileURLWithPath: path))

        return path
       }
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        navigationItem.backButtonTitle = "Back"
        
        
        viewStudyProgressButtonOutlet.titleLabel?.numberOfLines = 1
        viewStudyProgressButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        viewStudyProgressButtonOutlet.titleLabel?.minimumScaleFactor = 0.1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        words = selectedList.wordsArray
        titleLabel.text = selectedList.entity.listName
        tableViewOutlet.reloadData()
        
        if startTest {
            performSegue(withIdentifier: "moveToTest", sender: self)
            startTest = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isBaselineTest = false

        totalMastery = selectedList.entity.calculateMastery()
        totalMasteryLabelOutlet.text = "\(Double(round(10 * (totalMastery * 100)) / 10) )%"
        setUpCircularProgressBarView(scoreRatio: totalMastery)
        UIView.animate(withDuration: 0.25) { [self] in
            self.circularProgressBarView.alpha = 1
        }
        
        if !selectedList.entity.baselineTestOptOut && selectedList.entity.baselineTestScore == -1 && !dialogDisplaying {
            var decisionTree: [treeItem] = []
            decisionTree.append(treeItem(textPages: ["Hi Flash here, I recommend taking a baseline test first so that we can gauge how many of the words you already know. Would you like to do that now?"], options: [["Start Baseline Test", "Skip Baseline Test"]]))
            dialogDisplaying = true
            let tree = DecisionTreeView(frame: view.frame, decisionTree: decisionTree)
            view.addSubview(tree)
            tree.tutorialResponseDelegate = self
            tree.translatesAutoresizingMaskIntoConstraints = false
            tree.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tree.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tree.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tree.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tree.center.x = -tree.frame.width / 2
            
            UIView.animate(withDuration: 1) {
                tree.center.x = tree.frame.width / 2
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "editList":
            let controller = segue.destination as! CreateSpellingListViewController
            controller.editingList = selectedList
        case "moveToTest":
            let controller = segue.destination as! TestViewController
            controller.wordList = selectedList
            controller.isBaselineTest = isBaselineTest
            if let testInProgress = selectedList.entity.testInProgress {
                let wordsEntered = try! JSONDecoder().decode([String].self, from: testInProgress.wordsEntered!)
                controller.wordsEntered = wordsEntered
                controller.currentWordIndex = Int(testInProgress.currentWordIndex)
               
            }
            
        case "moveToPractice":
            let controller = segue.destination as! PracticeViewController
            controller.selectedList = selectedList
            controller.listOfWords = words
            
        case "moveToGame":
            let controller = segue.destination as! GamesSelectionViewController
            controller.selectedList = selectedList
            
        case "showStats":
            let controller = segue.destination as! StatAndTestViewController
            controller.selectedList = selectedList
            controller.listMastery = totalMastery
            
        default:
            return
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        circularProgressBarView.removeFromSuperview()
    }
}
// MARK: -


extension SpellingListViewController: tutorialResponseDelegate {
    func selectedOption(optionIndex: Int) {
        dialogDisplaying = false
        switch optionIndex {
        case 0:
            isBaselineTest = true
            performSegue(withIdentifier: "moveToTest", sender: self)
        case 1:
            selectedList.entity.baselineTestOptOut = true
            
            do {
                try context.save()
            } catch {
                
            }
        default:
            break
        }
    }
    
    
}
