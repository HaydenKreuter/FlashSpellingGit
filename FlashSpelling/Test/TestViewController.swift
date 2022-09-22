//
//  TestViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/2/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Outlets
    @IBOutlet weak var enterWordParentViewOutlet: UIView!
    @IBOutlet weak var finishButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var testTableViewOutlet: UITableView!
    @IBOutlet weak var wordNumberLabelOutlet: UILabel!
    @IBOutlet weak var wordTextFieldOutlet: UITextField!
    @IBOutlet weak var enterButtonOutlet: UIButton!
    @IBOutlet weak var navigationBarOutlet: UINavigationItem!
    @IBOutlet weak var playbuttonOutlet: UIButton!
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    // MARK:
    
    var wordList: WordList!
    var allWords: [WordEntity] = []
    var wordsEntered: [String] = []
    
    var currentWordIndex: Int = 0
    var playButtonController: PlayButtonController!
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    var isBaselineTest: Bool!
    var context: NSManagedObjectContext!
    
    var isPresentingTutorial: Bool = false
    
    
    // MARK: - Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsEntered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = testTableViewOutlet.dequeueReusableCell(withIdentifier: "testCell") as! TestTableViewCell
        cell.index = indexPath.item
        cell.delegate = self
        cell.wordLabelOutlet.text = wordsEntered[indexPath.item]
        cell.wordNumberOutlet.text = String(indexPath.item + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editWord(index: indexPath.row)
    }
    
    
    // MARK: - IB Outlet Actions

    @IBAction func PlayButtonPressed(_ sender: UIButton) {
        if currentWordIndex < allWords.count {
            let currentWord = allWords[currentWordIndex]
            playButtonController.play(path: currentWord.recordingPath!, word: currentWord.wordName!)
        }
    }
    
    
    
    @IBAction func enterPressed(_ sender: UITextField) {
        onEnter()

    }
    
    @IBAction func secondaryEnterPressed(_ sender: UIButton) {
        onEnter()

    }
    
    func onEnter() {
        saveCurrentWord()
        moveToWord()
        
        if currentWordIndex == allWords.count - 1 {
            finishButtonOutlet.isEnabled = true
        }
        
        if currentWordIndex < wordsEntered.count {
            testTableViewOutlet.scrollToRow(at: IndexPath(item: currentWordIndex, section: 0), at: .bottom, animated: false)
        } else if currentWordIndex - 1 < wordsEntered.count {
            testTableViewOutlet.scrollToRow(at: IndexPath(item: currentWordIndex - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIBarButtonItem) {
        // Create Alert
        if wordsEntered.count > 0 {
            if !wordTextFieldOutlet.text!.isEmpty {
                saveCurrentWord()
            }
            
            let alert = UIAlertController(title: "Save and Exit?", message: "Are you sure you want to exit the test? All progress will be saved.", preferredStyle: .alert)

           
            let saveAndExit = UIAlertAction(title: "Save and Exit", style: .default, handler: { [self] _ in
                saveCurrentTest()
                navigationController?.popViewController(animated: true)
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)


            alert.addAction(saveAndExit)
            alert.addAction(cancel)

            // Present alert message to user
            self.present(alert, animated: true, completion: nil)
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func finishPressed(_ sender: UIBarButtonItem) {
        saveCurrentWord()
        
        var emptyIndexes: [Int] = []
        for (i, wordsEnter) in wordsEntered.enumerated() {
            if wordsEnter.isEmpty {
                emptyIndexes.append(i + 1)
            }
        }
        
        if emptyIndexes.isEmpty {
            performSegue(withIdentifier: "moveToTestResults", sender: self)
        } else {
            var unenteredString = "\(emptyIndexes[0])"
            
            for i in emptyIndexes.dropLast().dropFirst() {
                unenteredString += ", \(i)"
            }
            if emptyIndexes.count > 1 {
                unenteredString += " and \(emptyIndexes.last!)"
            }
            
            
            let alert = UIAlertController(title: "Are you sure you're done?", message: "You have not entered anything for word \(unenteredString), you can go back to a skipped word by tapping the edit button to the left of the word's number in the list.", preferredStyle: .alert)

           
            let saveAndExit = UIAlertAction(title: "Finish Test", style: .destructive, handler: { [self] _ in
                performSegue(withIdentifier: "moveToTestResults", sender: self)
            })
            let cancel = UIAlertAction(title: "Keep Working", style: .cancel)


            alert.addAction(saveAndExit)
            alert.addAction(cancel)

            // Present alert message to user
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    func saveCurrentTest() {
        let testInProgress = TestInProgressEntity(context: context)
        let wordListAsString: String = wordsEntered.description
        let wordListAsData = wordListAsString.data(using: String.Encoding.utf16)
    
        testInProgress.wordsEntered = wordListAsData
        testInProgress.currentWordIndex = Int16(currentWordIndex)
        testInProgress.wordListEntry = wordList.entity
        do {
            try context.save()
        } catch {
            print("Could not save test in progress")
        }
    }
    
    func moveToWord(_ index: Int = -1) {
        // move to the next word
    
        if currentWordIndex != allWords.count - 1 || index != -1 {
            if !wordTextFieldOutlet.isFirstResponder {
                enterWordParentViewOutlet.isHidden = false
                wordTextFieldOutlet.becomeFirstResponder()
            }
            
            if index == -1 {
                currentWordIndex += 1
    
            } else {
                
                currentWordIndex = index
                
            }
            if currentWordIndex < wordsEntered.count {
                wordTextFieldOutlet.text = wordsEntered[currentWordIndex]
            } else {
                wordTextFieldOutlet.text = ""
                enterButtonOutlet.setTitle("Skip", for: .normal)
                
            }
            
            wordNumberLabelOutlet.text = "\(currentWordIndex + 1)."
            
            let nextWord = allWords[currentWordIndex]
            playButtonController.play(path: nextWord.recordingPath!, word: nextWord.wordName!)
        } else {
            enterWordParentViewOutlet.isHidden = true
            wordTextFieldOutlet.resignFirstResponder()
        }
        
    }
    
    func saveCurrentWord() {
        // save the current entry
        if var textEntered = wordTextFieldOutlet.text {

            textEntered = textEntered.lowercased()
            textEntered = textEntered.trimmingCharacters(in: .whitespaces)
            if currentWordIndex < wordsEntered.count { // edit past entry
                wordsEntered[currentWordIndex] = textEntered

            } else if wordsEntered.count < allWords.count {
                wordsEntered.append(textEntered)
            }
            testTableViewOutlet.reloadData()
            
        }
    }
    
    @IBAction func tutorialPressed(_ sender: Any) {
        presentTutorial()
    }
    
    
    func presentTutorial() {
        if !isPresentingTutorial {
            wordTextFieldOutlet.resignFirstResponder()
            let tutorialView = TutorialView(frame: view.frame, pages: ["Let's go over how to take your test!","Press the yellow play button to listen to the word. If you can not hear the word, make sure you have your volume turned up.", "Type the word you hear in the text field at the bottom and press the enter button.", "You can skip a word by pressing the red skip button, and come back to it later by selecting the number of the word in the list.", "After you have entered all the words, press the 'Finish test!' button at the top right corner.", "It is important to take the test without any outside help or looking at your word list, if you don't know a word, just press the 'skip button'. Remember, this is to help you learn!"])
            view.addSubview(tutorialView)
            tutorialView.translatesAutoresizingMaskIntoConstraints = false
            tutorialView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tutorialView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tutorialView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tutorialView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tutorialView.center.x = -tutorialView.frame.width / 2
            tutorialView.delegate = self
            isPresentingTutorial = true
            UIView.animate(withDuration: 1) {
                tutorialView.center.x = tutorialView.frame.width / 2
            }
        }
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        navigationBarOutlet.hidesBackButton = true
        playButtonController = PlayButtonController(audioPlayer: audioPlayer, button: playbuttonOutlet)
        allWords = wordList.wordsArray
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
       
        testTableViewOutlet.rowHeight = 80
        
        //setting audio session
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            } catch {
            }
        }
        
        if wordTextFieldOutlet.text!.isEmpty {
            enterButtonOutlet.setTitle("Skip", for: .normal)
        }
        finishButtonOutlet.isEnabled = (wordsEntered.count == allWords.count)
        
        wordNumberLabelOutlet.text = "\(currentWordIndex + 1)."
        if currentWordIndex < wordsEntered.count {
            wordTextFieldOutlet.text = wordsEntered[currentWordIndex]
        }
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let currentWord = allWords[currentWordIndex]
        if !UserDefaults.standard.bool(forKey: "testTutorialPlayed") {
            presentTutorial()
            
        } else {
            wordTextFieldOutlet.becomeFirstResponder()
            playButtonController.play(path: currentWord.recordingPath!, word: currentWord.wordName!)
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToTestResults" {
            let controller = segue.destination as! TestResultsViewController
            controller.wordList = self.wordList
            controller.wordsEntered = self.wordsEntered
            controller.allWords = self.allWords
            controller.isBaselineTest = self.isBaselineTest
            
        }
    }

    
    @objc func appMovedToBackground(notification: NSNotification) {
        if wordsEntered.count > 0 {
            saveCurrentWord()
            saveCurrentTest()
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
      guard let userInfo = notification.userInfo else { return }

      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let endFrameY = endFrame?.origin.y ?? 0
      let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

      if endFrameY >= UIScreen.main.bounds.size.height {
        self.keyboardHeightLayoutConstraint?.constant = 0.0
      } else {
        self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height ?? 85) + 15
      }

      UIView.animate(
        withDuration: duration,
        delay: TimeInterval(0),
        options: animationCurve,
        animations: { self.view.layoutIfNeeded() },
        completion: nil)
    }
    
    // MARK: - 
    
    @IBAction func textChanged(_ sender: UITextField) {
        if sender.text!.isEmpty {
            enterButtonOutlet.setTitle("Skip", for: .normal)
        } else {
            if currentWordIndex == allWords.count - 1 {
                enterButtonOutlet.setTitle("Done", for: .normal)
                finishButtonOutlet.isEnabled = true
            } else {
                enterButtonOutlet.setTitle("Next", for: .normal)
            }
            
        }
    }
    
    
}


extension TestViewController: testTableViewCellDelegate {
    func editWord(index: Int) {
        if index < allWords.count {
            saveCurrentWord()
            moveToWord(index)
        }
    }
    
}

extension TestViewController: tutorialDismisssedDelegate {
    func tutorialDismissed() {
        let currentWord = allWords[currentWordIndex]
        isPresentingTutorial = false
        UserDefaults.standard.set(true, forKey: "testTutorialPlayed")
        wordTextFieldOutlet.becomeFirstResponder()
        playButtonController.play(path: currentWord.recordingPath!, word: currentWord.wordName!)
    }
    
    
}

