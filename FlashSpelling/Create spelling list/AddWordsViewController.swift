//
//  addWordsViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/15/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import UserNotifications

class AddWordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var context: NSManagedObjectContext!
    var wordEditing = -1 // indicates the index of the word being edited no word = -1

    
    // MARK: - UI Element Outlets
    @IBOutlet weak var navigationBarOutlet: UINavigationItem!
    @IBOutlet weak var addWordTableViewOutlet: UITableView!
    @IBOutlet weak var wordNumberLabelOutlet: UILabel!
    @IBOutlet weak var audioSwitchOutlet: UISwitch!
    @IBOutlet weak var recordButtonOutlet: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var secondaryEnterButtonOutlet: UIButton!
    @IBOutlet weak var enterWordTextFieldOutlet: UITextField!
    
    // MARK: - Passed from CreateSpellingListViewController
    var listOfWords: [String] = [] // array of words
    var listOfAudioPaths: [String] = [] // list of audio paths, 0 is automatic audio speech (runs in parallel with listOfWords)
    var listTitle: String? // name of list

    var testDate: Date? // date of test optional by user
    var editingList: WordList?
    var dateCreated: Date?
    
    // MARK: - Audio Vars
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var currentWordAudioPath: String? // path to audio uuid.m4a
    var timer = Timer() // audio timer
    var recordTime = 0 // keeps track of recording time
    
    var playButtonController: PlayButtonController!
    
    var tutorialIsPresented = false

    // MARK: - Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addWordTableViewOutlet.dequeueReusableCell(withIdentifier: "wordCell") as! AddWordsTableViewCell
        cell.wordLabel.text = listOfWords[indexPath.item]
        cell.wordNumberLabel.text = "\(indexPath.item + 1)"
        cell.delegate = self
        cell.index = indexPath.item
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { // deletes table view item when swiping left on item
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteWord(index: indexPath.item, effect: 0)
        }
        return [delete]
        
    }
    
    
    // MARK: - UI Button/ Event Actions
    @IBAction func audioSwichToggled(_ sender: UISwitch) {
        updateButtons()
    }
    

    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil { // no current recording start new recording
            // check for permissions
            AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
                if hasPermission {
                    DispatchQueue.main.async {
                        let settingsToRecord = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                        
                        do {
                            let uuid = UUID().uuidString + ".m4a"
                            self.currentWordAudioPath = uuid
                            let fileName = self.getDirectory().appendingPathComponent(uuid)
                            self.audioRecorder = try AVAudioRecorder(url: fileName, settings: settingsToRecord)
                            self.audioRecorder.delegate = self
                            self.audioRecorder.record()
                            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AddWordsViewController.counter), userInfo: nil, repeats: true)
                            self.playButtonOutlet.isEnabled = false
                            self.recordButtonOutlet.setImage(UIImage(named: "recordButtonState2"), for: .normal)
                            self.recordTime = 0
                            
                        } catch {
                            let alert = UIAlertController(
                                title: "Unable To Access Microphone",
                                message: "An error has occurred when attempting to record, please restart device and try again. For help please contact our support team.",
                                preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Okay", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                    
                } else {
                    let alert = UIAlertController(
                        title: "Unable To Access Microphone",
                        message: "We need your permission to use the microphone for recording your words. To check permissions go to Settings, scroll down to \"My Spelling School\", and ensure that the setting for microphone is enabled ",
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default))
                    self.present(alert, animated: true)
                    
                }
            }
        
        } else { // recording is active so stop recording
            stopRecording()
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if let text = enterWordTextFieldOutlet.text {
            if audioSwitchOutlet.isOn || currentWordAudioPath == nil { // automatic pronunciation is on
                playButtonController.play(path: "0", word: text)
            } else {
                playButtonController.play(path: currentWordAudioPath!, word: text)
            }
            
        }
    }
    
    @IBAction func enterPressed(_ sender: UITextField) {
        addWord(withMessage: true)
    }
    
    @IBAction func secondaryEnterPressed(_ sender: UIButton) {
        addWord(withMessage: true)
    }
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        // saves list to core data
        addWord(withMessage: false)
        if listOfWords.count > 2 && listOfWords.count == listOfAudioPaths.count {
            if let list = editingList { // editing list
                list.entity.listName = listTitle
                list.entity.testDate = testDate
                
                var updateIndexes: [Int] = []
                for word in list.entity.wordEntity! {
                    let wordEntity = word as! WordEntity
                    if listOfWords.contains(wordEntity.wordName!) { // word already in list
                        let index: Int = listOfWords.firstIndex(of: wordEntity.wordName!)!
                        updateIndexes.append(index)
                        wordEntity.recordingPath = listOfAudioPaths[index]
                        wordEntity.order = Int16(index)
                    } else { // word removed
                        context.delete(wordEntity)
                        if wordEntity.recordingPath != "0" {
                            let file = getDirectory().appendingPathComponent(wordEntity.recordingPath!)
                            do {
                                try FileManager.default.removeItem(at: file)
                            } catch {
                                print("Could not delete file")
                            }
                        }
                    }
                }
                for index in 0...listOfWords.count - 1 {
                    if !updateIndexes.contains(index) { // word was not updated so it is new
                        let newWord = WordEntity(context: context)
                        newWord.wordName = listOfWords[index]
                        newWord.recordingPath = listOfAudioPaths[index]
                        newWord.wordListEntity = list.entity
                        newWord.order = Int16(index)
                    }
                }
                
            } else { // new list
                var newList: WordListEntity!
                newList = WordListEntity(context: context)
                newList.listName = listTitle!
                newList.baselineTestOptOut = false
                newList.baselineTestScore = -1
                
                if let date = dateCreated {
                    newList.dateCreated = date
                } else {
                    let date = Date()
                    newList.dateCreated = date
                }
                
                
                if let test = testDate {
                    newList.testDate = test
                } else if newList.testDate != nil {
                    newList.testDate = nil
                }
                
                for index in 0...listOfWords.count - 1 {
                    let newWord = WordEntity(context: context)
                    newWord.wordName = listOfWords[index]
                    newWord.recordingPath = listOfAudioPaths[index]
                    newWord.wordListEntity = newList
                    newWord.order = Int16(index)
                }
            }
            
            do {
                try context.save()
            } catch {
                print("could not save")
            }
            
            
            navigationController?.popToRootViewController(animated: true)
            

        } else {
            let alert = UIAlertController(
                title: "List Not Complete",
                message: "Please ensure that you have added at least 3 words to your list, and that all words have a pronunciation recorded or have automatic pronunciation enabled",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
        }

    }
    @IBAction func helpButtonPressed(_ sender: UIBarButtonItem) {
        if !tutorialIsPresented {
            runTutorial()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if wordEditing != -1 { // cancel editing
            wordEditing = -1
            currentWordAudioPath = nil
            audioRecorder = nil
            audioPlayer = nil
            updateButtons()
            enterWordTextFieldOutlet.placeholder = "Enter new word"
            wordNumberLabelOutlet.text = "\(listOfWords.count + 1)"
            doneButtonOutlet.setTitle("Done", for: .normal)
            enterWordTextFieldOutlet.text = ""
        }
        enterWordTextFieldOutlet.resignFirstResponder()
    }
    
    // MARK: - Functions
    func stopRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        recordButtonOutlet.setImage(UIImage(named: "recordButtonState4"), for: .normal)
        timer.invalidate()
        playButtonOutlet.isEnabled = true
    }
    
    
    @objc func counter() { // called every second after recording starts
        recordTime += 1
        if recordTime > 30 {
            stopRecording()
            
        }
        if recordTime.isMultiple(of: 2) {
            recordButtonOutlet.setImage(UIImage(named: "recordButtonState3"), for: .normal)
        } else {
            recordButtonOutlet.setImage(UIImage(named: "recordButtonState2"), for: .normal)
        }
        
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButtonOutlet.setImage(UIImage(named: "playButton"), for: .normal)
    }
    
    
    func updateButtons() {
        if audioSwitchOutlet.isOn {
            if audioRecorder != nil {
                stopRecording()
            }
            recordButtonOutlet.isEnabled = false
            playButtonOutlet.isEnabled = true
        } else {
            
            recordButtonOutlet.isEnabled = true
            if wordEditing != -1 { // editing a word
                if listOfAudioPaths[wordEditing] == "0" { // checks if automatic audio is being used (no audio recorded)
                    recordButtonOutlet.setImage(UIImage(named: "recordButtonState1"), for: .normal)
                    playButtonOutlet.isEnabled = false
                } else { // word already recorded
                    recordButtonOutlet.setImage(UIImage(named: "recordButtonState4"), for: .normal)
                    playButtonOutlet.isEnabled = true
                }
            } else { // new word
                recordButtonOutlet.setImage(UIImage(named: "recordButtonState1"), for: .normal)
                playButtonOutlet.isEnabled = true
                playButtonOutlet.isEnabled = false
            }
        }
    }
    
    func getDirectory() -> URL { // gets path to directory  to save audio recordings
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    func addWord(withMessage: Bool) {
        // stop audio recording if in progress
        if audioRecorder != nil {
            stopRecording()
        }

        var word = enterWordTextFieldOutlet.text!.trimmingCharacters(in: .whitespaces)
        if word.count >= 3 {
            word = word.lowercased()
            if !audioSwitchOutlet.isOn {
                playButtonOutlet.isEnabled = false
            }
            
            if !listOfWords.contains(word) {
                if wordEditing != -1 { // is editing word
                    listOfWords[wordEditing] = enterWordTextFieldOutlet.text! // save word in index of wordEditing
                    deactivateEdit()
                    addWordTableViewOutlet.reloadData()
                    
                } else { // entering a new word
                    if audioSwitchOutlet.isOn { // checks audio choice and saves accordingly
                        listOfAudioPaths.append("0")
                    } else {
                        if currentWordAudioPath != nil {
                            listOfAudioPaths.append(currentWordAudioPath!)
                            currentWordAudioPath = nil
                        } else {
                            let alert = UIAlertController(
                                title: "No Audio recorded",
                                message: "Record the pronunciation for this word by clicking the red record button, or turn on \"Automatic Pronunciation\" to generate a Computerized pronunciation.",
                                preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default))
                            self.present(alert, animated: true)
                            
                            return
                        }
                    }
                    timer.invalidate()
                    currentWordAudioPath = nil
                    recordButtonOutlet.setImage(UIImage(named: "recordButtonState1"), for: .normal)
                    listOfWords.append(word)
                    enterWordTextFieldOutlet.text = ""
                    wordNumberLabelOutlet.text = "\(listOfWords.count + 1)"
                    addWordTableViewOutlet.reloadData()
                    addWordTableViewOutlet.scrollToRow(at: IndexPath(item: listOfWords.count - 1, section: 0), at: .top, animated: true)
                }
            } else { // word is already entered
                if wordEditing != -1  {
                    // deactivate edit
                    deactivateEdit()
                }
            }
        } else if withMessage { // no word is entered
            let alert = UIAlertController(title: "Invalid Word", message: "Please enter a word of at least 3 letters to add it to the list", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
            
        }
    }
    
    
    func deactivateEdit() {
        // saves audio preference
        if audioSwitchOutlet.isOn { // automatic audio
            listOfAudioPaths[wordEditing] = "0"
            
        } else { // record audio
            if currentWordAudioPath != nil {
                listOfAudioPaths[wordEditing] = currentWordAudioPath!
            } else { // no audio recorded
            }
        }
        wordEditing = -1
        enterWordTextFieldOutlet.text = ""
        enterWordTextFieldOutlet.placeholder = "Enter new word"
        wordNumberLabelOutlet.text = "\(listOfWords.count + 1)"
        doneButtonOutlet.setTitle("Done", for: .normal)
        recordButtonOutlet.setImage(UIImage(named: "recordButtonState1"), for: .normal)
        currentWordAudioPath = nil
    }
    
    // MARK: - Keyboard Events
    @objc func keyboardWillHide() {
        addWordTableViewOutlet.contentInset.bottom = 0
        addWordTableViewOutlet.scrollIndicatorInsets.bottom = 0
    }
    
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addWordTableViewOutlet.contentInset.bottom = keyboardSize.height
            addWordTableViewOutlet.scrollIndicatorInsets.bottom = keyboardSize.height
        }
    }
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if testDate != nil {
            let cal = Calendar(identifier: .gregorian)
            testDate = cal.startOfDay(for: testDate!)
        }
        
        addWordTableViewOutlet.rowHeight = 80
        addWordTableViewOutlet.layer.cornerRadius = 7
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        //setting audio session
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            } catch {
            }
        }
        
        if audioSwitchOutlet.isOn {
            recordButtonOutlet.isEnabled = false
        } else {
            playButtonOutlet.isEnabled = false
        }
        if let list = editingList {
            for word in list.wordsArray {
                self.listOfWords.append(word.wordName!)
                self.listOfAudioPaths.append(word.recordingPath!)
            }
            self.dateCreated = list.dateCreated
            
        }
        
        playButtonController = PlayButtonController(audioPlayer: audioPlayer, button: playButtonOutlet)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "addWordTutorial") == false {
            runTutorial()
        }
    }
    
    func runTutorial() {
        tutorialIsPresented = true
        let tutorialView = TutorialView(frame: view.frame, pages: ["Let's add some words! To add a word start by typing it into the text field at the top.", "Automatic pronunciation is enabled by default, which will have the computer speak the words to you.", "To record your own voice instead, you can toggle automatic pronunciation off, and then press the red record button to record you saying the word.", "Press the yellow play button to hear the current recording of the word. Press enter to add the word to your list and when you are finished tap the 'finished' button at the top.", "You can also edit words you entered by selecting the pencil icon to the left of the word. To see this tutorial again, you can click the 'tutorial' button at the top of the screen."])
        tutorialView.delegate = self
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
        UserDefaults.standard.set(true, forKey: "addWordTutorial")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        addWord(withMessage: false)
    }
    
    // MARK: -

}




extension AddWordsViewController: addWordCellDelegate {
    
    func deleteWord(index: Int, effect: Int) {
        if wordEditing != -1 {
            deactivateEdit()
        }
        listOfWords.remove(at: index)
        
        if listOfAudioPaths[index] != "0" {
            let file = getDirectory().appendingPathComponent(listOfAudioPaths[index])
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Could not delete file")
            }
        }
         listOfAudioPaths.remove(at: index)
        addWordTableViewOutlet.performBatchUpdates({
            addWordTableViewOutlet.deleteRows(at: [IndexPath(item: index, section: 0)], with: .left)
        }) { (complete) in
            if complete {
                self.addWordTableViewOutlet.reloadData()
            }
        }
        
        if index == wordEditing || index == listOfWords.count - 1 { // deleting current item
            currentWordAudioPath = nil
            updateButtons()
        }
        wordNumberLabelOutlet.text = "\(listOfWords.count + 1)"
    }
    
    func editWord(index: Int) {
        if wordEditing != index {
            if wordEditing != -1 {
                addWord(withMessage: false)
            }
            wordEditing = index
            wordNumberLabelOutlet.text = "\(index + 1)"
            enterWordTextFieldOutlet.text = listOfWords[index]
            addWordTableViewOutlet.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .top)
            enterWordTextFieldOutlet.placeholder = "Edit word: \(listOfWords[index])"
            doneButtonOutlet.setTitle("Cancel", for: .normal)
            enterWordTextFieldOutlet.becomeFirstResponder()
            
            if listOfAudioPaths[index] == "0" { // automatic audio
                audioSwitchOutlet.isOn = true
                playButtonOutlet.isEnabled = true
                recordButtonOutlet.isEnabled = false
            } else {
                audioSwitchOutlet.isOn = false
                recordButtonOutlet.isEnabled = true
                playButtonOutlet.isEnabled = true
                recordButtonOutlet.setImage(UIImage(named: "recordButtonState4"), for: .normal)
                currentWordAudioPath = listOfAudioPaths[index]
                
            }
            
        }

    }
}



extension AddWordsViewController: tutorialDismisssedDelegate {
    func tutorialDismissed() {
        tutorialIsPresented = false
    }
    
    
}
