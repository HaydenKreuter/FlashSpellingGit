//
//  PracticeViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/26/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PracticeViewController: UIViewController {
    // MARK: - Variables
    var listOfWords: [WordEntity] = []
    var wordsMarkedForRepeat: Set<WordEntity> = []
    var currentWord: WordEntity!
    var multipleChoiceView: MultipleChoiceView!
    var typeWordView: TypeWordView!
    var context: NSManagedObjectContext!
    var selectedList: WordList!
    
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    var playButtonController: PlayButtonController!

    
    @IBOutlet weak var playBarButtonItemOutlet: UIBarButtonItem!
    @IBOutlet weak var leadingLabelOutlet: UILabel!
    @IBOutlet weak var progressSliderOutlet: UISlider!
    @IBOutlet weak var goalLabelOutlet: UILabel!
    @IBOutlet weak var topStackViewOutlet: UIStackView!
    var goalPoints: Int = 0
    var currentPoints: Int = 0
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        playButtonController = PlayButtonController(audioPlayer: audioPlayer, barButton: playBarButtonItemOutlet)

        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            } catch {
            }
        }
        playBarButtonItemOutlet.image = UIImage(named: "playButton")
        listOfWords.sort(by: { $0.mastery < $1.mastery })
        
    
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        goalPoints = setGoal()
        goalLabelOutlet.text = "Goal\n\(goalPoints)"
        leadingLabelOutlet.text = "0\npoints"
        progressSliderOutlet.minimumValue = 0
        progressSliderOutlet.maximumValue = Float(goalPoints)
        progressSliderOutlet.value = 0
        currentPoints = 0
        nextWord()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "endPractice" {
            let controller = segue.destination as! PracticeEndViewController
            controller.selectedList = selectedList
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
       
        if multipleChoiceView != nil {
            multipleChoiceView.removeFromSuperview()
        }
        if typeWordView != nil {
            typeWordView.removeFromSuperview()
        }
        
        
    }
    
    // MARK: - Functions 
    
    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        playButtonController.play(path: currentWord.recordingPath!, word: currentWord.wordName!)
    }
    
    @IBAction func exitButtonPressed(_ sender: UIBarButtonItem) {
        if currentPoints == 0 {
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "End Practice Session", message: "Are you sure you want to end your practice session early?", preferredStyle: .alert)

           
            let end = UIAlertAction(title: "End", style: .destructive, handler: { [self] _ in
                performSegue(withIdentifier: "endPractice", sender: self)
                
            })
            let cancel = UIAlertAction(title: "Keep Practicing", style: .cancel)


            alert.addAction(end)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }

    }
    
    func setGoal() -> Int {
        let numberOfWords = selectedList.wordsArray.count
        return (100 * numberOfWords)
    }
    
    
    func updatePoint(points: Int) {
        currentPoints += points
        UIView.animate(withDuration: 0.5) { [self] in
            leadingLabelOutlet.text = "points\n\(currentPoints)"
            progressSliderOutlet.setValue(Float(currentPoints), animated: true)
        }


    }
    
    func playSoundEffect(name: String) {

        do {
            let soundEffectPlayer = Bundle.main.path(forResource: name, ofType: "m4a")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: soundEffectPlayer!)as URL)
            audioPlayer.volume = 0.35
            audioPlayer.play()
            audioPlayer.volume = 1
        } catch {
            print("could not play sound effect")
        }
    
    }
    
    func nextWord() {
        if wordsMarkedForRepeat.count > 0 {
            let selectedWord = wordsMarkedForRepeat.randomElement()
            if selectedWord != currentWord {
                currentWord = selectedWord
            } else {
                currentWord = listOfWords.first
                listOfWords.removeFirst()
                listOfWords.append(currentWord)
            }
            
        } else {
            currentWord = listOfWords.first
            listOfWords.removeFirst()
            listOfWords.append(currentWord)
        }
        
        if currentWord.mastery > 50 {
            typeWordView = TypeWordView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), word: currentWord)
            typeWordView.delegate = self
            self.view.addSubview(typeWordView)
            
            typeWordView.translatesAutoresizingMaskIntoConstraints = false
            typeWordView.topAnchor.constraint(equalTo: topStackViewOutlet.bottomAnchor, constant: 15).isActive = true
            typeWordView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
            typeWordView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            typeWordView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 15).isActive = true
            typeWordView.isUserInteractionEnabled = true
            
            typeWordView.center.x = -view.frame.width * 2
            UIView.animate(withDuration: 1) { [self] in
                typeWordView.center.x = 0
            }
            
            
        } else {
            multipleChoiceView = MultipleChoiceView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), word: currentWord)
            multipleChoiceView.delegate = self
            self.view.addSubview(multipleChoiceView)
            
            multipleChoiceView.translatesAutoresizingMaskIntoConstraints = false
            multipleChoiceView.topAnchor.constraint(equalTo: topStackViewOutlet.bottomAnchor, constant: 15).isActive = true
            multipleChoiceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
            multipleChoiceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            multipleChoiceView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 15).isActive = true
            multipleChoiceView.isUserInteractionEnabled = true
            
            multipleChoiceView.center.x = -view.frame.width * 2
            UIView.animate(withDuration: 1) { [self] in
                multipleChoiceView.center.x = 0
            } 

        }
        playButtonController.play(path: currentWord.recordingPath!, word: currentWord.wordName!)
    }

}

// MARK: - Extensions
extension PracticeViewController: multipleChoiceViewDelegate {
    func finishedMultipleChoiceEntry(attempts: Int) {
        selectedList.entity.wordsStudied += 1
        selectedList.entity.updateDayWordsStudied()
        UIView.animate(withDuration: 1) { [self] in
            multipleChoiceView.frame.origin.x = view.frame.width * 2
        } completion: { [self] _ in
            multipleChoiceView.removeFromSuperview()
            view.layoutSubviews()
            
            if attempts == 0 {
                currentWord.updateMastery(20)
                updatePoint(points: 80)
                wordsMarkedForRepeat.remove(currentWord)
            } else {
                wordsMarkedForRepeat.insert(currentWord)
                var update = Double(attempts) * -5.0
                updatePoint(points: 10)
                if update < -15 {
                    update = -15
                }
                currentWord.updateMastery(update)

            }
            do {
                try context.save()
            } catch {
                
            }
            if currentPoints >= goalPoints {
                performSegue(withIdentifier: "endPractice", sender: self)
            } else {
                nextWord()
            }
            
        }

    }
    
    func playCorrectSound() {
        playSoundEffect(name: "correct")
    }
}

extension PracticeViewController: typeWordViewDelegate {
    func finishedTextEntry(similarity: Int, redemptionActive: Bool) {
        selectedList.entity.wordsStudied += 1
        selectedList.entity.updateDayWordsStudied()
        UIView.animate(withDuration: 1) { [self] in
            typeWordView.frame.origin.x = view.frame.width * 2
        } completion: { [self] _ in
            if similarity == 0 {
                currentWord.updateMastery(25)
                updatePoint(points: 100)
                wordsMarkedForRepeat.remove(currentWord)
            } else {
                wordsMarkedForRepeat.insert(currentWord)
                var update = Double(similarity) * -4
                updatePoint(points: 20)
                if update < -12 {
                    update = -12
                }
       
                currentWord.updateMastery(update)
            }
            
            do {
                try context.save()
            } catch {
                
            }
            
            typeWordView.removeFromSuperview()
            view.layoutSubviews()
            if currentPoints >= goalPoints {
                performSegue(withIdentifier: "endPractice", sender: self)
            } else {
                nextWord()
            }
        }
    }
    
    
}
