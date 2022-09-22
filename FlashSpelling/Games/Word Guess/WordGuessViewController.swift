//
//  WordleViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/7/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import AVFoundation

class WordGuessViewController: UIViewController, keyboardActionDelegate, gameEndingPopupDelegate {

    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var possibleWordStackView: UIStackView!
    
    var contentView: UIView!
    var stackView: UIStackView!
    var textStackViews: [TextStackView] = []
    var currentRow: Int = 0
    
    var selectedList: WordList!
    var selectedWord: WordEntity!
    
    var points: Int = 0
    var spacing: CGFloat = 2
    var numberOfRows: Int = 3
    var currentText: String = ""

    var previousHeightConstraint: NSLayoutConstraint?
    
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    var playButtonController: PlayButtonController!
    var isReadyForInput: Bool = true
    
    var possibleWords: [WordEntity] = []
    
    var tutorialView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedWord = selectRandomWord(currentWord: "", currentList: selectedList)
        possibleWords.append(selectedWord)
        
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            } catch {
            }
        }
        
        var lowerBound = selectedWord.wordName!.count
        var upperBound = selectedWord.wordName!.count
        
        var numberOfPossibleWords: Int = 0
        if selectedList.wordsArray.count <= 5 {
            numberOfPossibleWords = selectedList.wordsArray.count
        } else {
            numberOfPossibleWords = 5
        }
        while possibleWords.count != numberOfPossibleWords {

            for word in selectedList.wordsArray {
                if Array(lowerBound...upperBound).contains(word.wordName!.count) && !possibleWords.contains(word) {
                    if possibleWords.count != numberOfPossibleWords {
                        
                        possibleWords.append(word)
                    } else {
                        break
                    }
                }
            }
            if lowerBound > 0 {
                lowerBound -= 1
            }
            upperBound += 1
        }
        
        for i in 0...possibleWords.count - 1 {
            let newButton: UIButton = UIButton()
            
            newButton.setTitle("\(i + 1)\n(tap to listen)", for: .normal)
            newButton.setTitleColor(UIColor.black, for: .normal)
            newButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 25)
         
            newButton.titleLabel?.adjustsFontSizeToFitWidth = true
            newButton.titleLabel?.numberOfLines = 2

            newButton.isUserInteractionEnabled = true
            newButton.isSpringLoaded = true
            newButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .highlighted)
            newButton.titleLabel?.textAlignment = .center
            newButton.backgroundColor = .lightText
            newButton.layer.cornerRadius = 12
            newButton.layer.borderWidth = 0
            newButton.tag = i
            newButton.addTarget(self, action: #selector(playPossibleWordPressed), for: .touchUpInside)
            newButton.imageView?.contentMode = .scaleAspectFit
            possibleWordStackView.addArrangedSubview(newButton)
        }
        possibleWords.shuffle()
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if contentView != nil {
            return
        }
        contentView = UIView()
        scrollViewOutlet.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: scrollViewOutlet.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: scrollViewOutlet.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollViewOutlet.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollViewOutlet.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollViewOutlet.widthAnchor).isActive = true
        
        setContentViewHeight(viewWidth: self.scrollViewOutlet.frame.width, contentView: contentView, numberOfLetters: self.selectedWord.wordName!.count, numberOfRows: self.numberOfRows, spacing: self.spacing)
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    
        
        for _ in 1...numberOfRows {
            let textStackView = TextStackView(selectedWord: self.selectedWord.wordName!, spacing: self.spacing)
            textStackView.delegate = self
            stackView.addArrangedSubview(textStackView)
            textStackViews.append(textStackView)
        }
        
        if UserDefaults.standard.bool(forKey: "guessThreeTutorialShown") {
            textStackViews.first?.becomeFirstResponder()
        } else {
            presentTutorial()
            UserDefaults.standard.set(true, forKey: "guessThreeTutorialShown")
        }
        
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setContentViewHeight(viewWidth: size.width - 20, contentView: contentView, numberOfLetters: selectedWord.wordName!.count, numberOfRows: numberOfRows, spacing: spacing)
    }
    
    @IBAction func helpPressed(_ sender: UIBarButtonItem) {
        if tutorialView == nil {
            textStackViews.first!.resignFirstResponder()
            presentTutorial()
        } else {
            dismissPressed()
        }

    }
    
    @objc func dismissPressed() {
        navigationItem.hidesBackButton = false
        for subview in tutorialView.subviews {
            subview.removeFromSuperview()
            
        }
        tutorialView.removeFromSuperview()
        tutorialView = nil
        textStackViews.first?.becomeFirstResponder()
    }
    
    @objc func playPossibleWordPressed(sender: UIButton) {
        if sender.imageView?.image != nil {
            playButtonController = PlayButtonController(audioPlayer: audioPlayer, button: sender)
            let selection = possibleWords[sender.tag]
            playButtonController.play(path: selection.recordingPath!, word: selection.wordName!)
        } else {
            sender.setTitle("", for: .normal)
            sender.setImage(UIImage(named: "playButton"), for: .normal)
            
            UIView.transition(with: sender,
                               duration: 0.5, options: .transitionFlipFromBottom,
                              animations: nil, completion: { [self] _ in
                playButtonController = PlayButtonController(audioPlayer: audioPlayer, button: sender)
                let selection = possibleWords[sender.tag]
                playButtonController.play(path: selection.recordingPath!, word: selection.wordName!)
                
            })
        }


    }
    
    func presentTutorial() {
        
        tutorialView = UIView()
        
        view.addSubview(tutorialView)
        navigationItem.hidesBackButton = true
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        tutorialView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tutorialView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tutorialView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tutorialView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tutorialView.backgroundColor = .white
        
        let tutorialImageView = UIImageView()
        tutorialImageView.image = UIImage(named: "guessThreeHelp")
        
        tutorialView.addSubview(tutorialImageView)
        tutorialImageView.translatesAutoresizingMaskIntoConstraints = false
        tutorialImageView.topAnchor.constraint(equalTo: tutorialView.topAnchor, constant: view.safeAreaInsets.top).isActive = true
        tutorialImageView.leftAnchor.constraint(equalTo: tutorialView.leftAnchor).isActive = true
        tutorialImageView.rightAnchor.constraint(equalTo: tutorialView.rightAnchor).isActive = true
        tutorialImageView.contentMode = .scaleAspectFit
        tutorialImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        tutorialImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let dismissButton = defaultButton()
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.backgroundColor = .theme.grey
        dismissButton.setTitleColor(.theme.white, for: .normal)

        dismissButton.isSpringLoaded = true
        dismissButton.setTitleColor(.white, for: .highlighted)
        dismissButton.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)

        tutorialView.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: tutorialImageView.bottomAnchor, constant: 10).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: tutorialView.centerXAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(lessThanOrEqualTo: tutorialView.bottomAnchor, constant: -view.safeAreaInsets.bottom).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        

    }
    
    
    func exitPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func appendText(text: String) {
        if !isReadyForInput {
            return
        }
        
        let validText = String(text[0]).lowercased()
        let currentTextStack: TextStackView = textStackViews[currentRow]
        if !((currentText.count + validText.count) > selectedWord.wordName!.count) {
            currentText += validText

            let currentTileLabel: UILabel = currentTextStack.letterTiles[currentText.count - 1]
            currentTileLabel.text = validText
            currentTileLabel.layer.borderColor = UIColor.gray.cgColor
            currentTileLabel.textColor = .black
            UIView.animate(withDuration: 0.01,
                animations: {
                currentTileLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        currentTileLabel.transform = CGAffineTransform.identity
                    }
                })
        } else {
            currentTextStack.shake()
        }
    }
    
    func enterPressed() {
        if !isReadyForInput {
            return
        }
        
        if currentText.count == selectedWord.wordName!.count { // check and move to next
            let currentTextStack = textStackViews[currentRow]
            let wordLetterArray: [Character] = Array(selectedWord.wordName!)
            isReadyForInput = false
            animateTile(currentTextStack: currentTextStack, wordLetterArray: wordLetterArray, i: 0)
            
        } else {
            displayMessage(message: "Not Enough Letters", duration: 1, parentView: self.view)
        }
    }
   
    
    func animateTile(currentTextStack: TextStackView, wordLetterArray: [Character], i: Int) {
        
        if i == wordLetterArray.count {
            if currentText == selectedWord.wordName! { // puzzle complete (won)
                endGame(gameWon: true)
            } else if currentRow == numberOfRows - 1 { // game lost
                endGame(gameWon: false)
                
            } else { // move to next row
                currentRow += 1
                currentText = ""
                isReadyForInput = true
            }
            
            return
        }
        
        let letterTile = currentTextStack.letterTiles[i]

        if letterTile.text! == String(wordLetterArray[i]) {
            letterTile.backgroundColor = UIColor.theme.blue
        } else if wordLetterArray.contains(Character(letterTile.text!)) {
            letterTile.backgroundColor = UIColor.theme.yellow
        } else {
            letterTile.backgroundColor = UIColor.theme.grey
        }
        letterTile.textColor = .white
    
        UIView.transition(with: letterTile,
                           duration: 0.5, options: .transitionFlipFromBottom,
                          animations: nil, completion: { [self] _ in
            animateTile(currentTextStack: currentTextStack, wordLetterArray: wordLetterArray, i: i + 1)
        })
    
    }
    
    
    func endGame(gameWon: Bool) {
        var title: String!
        var message: String!
        var imageName: String!
        
        if gameWon {
            title = "Great Job!"
            message = ""
            imageName = "happyFlash"
        } else {
            title = "Ooops!"
            message = "The correct word was: \(selectedWord!.wordName!)\nIt's okay! Try again"
            imageName = "sadFlash"
        }
        for textStack in textStackViews {
            textStack.resignFirstResponder()
        }
        
        let dark = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: dark)
        view.addSubview(blurView)
        blurView.alpha = 0.8
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let popup = GameEndingPopup(title: title, message: message, imageName: imageName)
        popup.delegate = self
        self.view.addSubview(popup)
        
        popup.clipsToBounds = true
        popup.layer.cornerRadius = 7
       
        var width = view.frame.width - 50
        var height = view.frame.height - 50
        
        if width > 250 {
            width = 250
        }
        if height > 500 {
            height = 500
        }
        
        popup.frame = CGRect(x: view.frame.width / 2 - (width / 2), y: view.frame.height / 2 - (height / 2), width: width , height: height)
        
        if gameWon {
            let confettiController = confettiController(parentView: view)
            view.layer.addSublayer(confettiController.confettiLayer)
        }

        
        navigationItem.hidesBackButton = true
        
    }
    
    func backspacePressed() {
        if !isReadyForInput {
            return
        }
        if !currentText.isEmpty {
            let currentTextStack: TextStackView = textStackViews[currentRow]
            let currentTileLabel: UILabel = currentTextStack.letterTiles[currentText.count - 1]
            currentTileLabel.text = ""
            currentTileLabel.layer.borderColor = UIColor.lightGray.cgColor
            currentText.removeLast()
        }

    }
    
    
    func selectRandomWord(currentWord: String, currentList: WordList) -> WordEntity {
        var selection = currentList.wordsArray.randomElement()!
        
        while selection.wordName! == currentWord {
            selection = currentList.wordsArray.randomElement()!
        }
        return selection
    }
    
    func setContentViewHeight(viewWidth: CGFloat, contentView: UIView, numberOfLetters: Int, numberOfRows: Int, spacing: CGFloat) {
        if let constraint = previousHeightConstraint {
            constraint.isActive = false
        }
        let rowHeight: CGFloat = ((viewWidth - (spacing * CGFloat(numberOfLetters) - 1)) / CGFloat(numberOfLetters))
        let viewHeight = rowHeight * CGFloat(numberOfRows) + (spacing * CGFloat(numberOfRows - 1))
        previousHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: viewHeight)
        previousHeightConstraint!.isActive = true
        
    }
    
    func displayMessage(message: String, duration: Double, parentView: UIView) {
        let labelSize: CGSize = CGSize(width: 150, height: 32)
        let labelOrgin: CGPoint = CGPoint(x: (parentView.frame.width / 2) - (labelSize.width / 2), y: parentView.safeAreaInsets.top + 5)
        let label = UILabel(frame: CGRect(origin: labelOrgin, size: labelSize))
        
        label.text = message
        label.backgroundColor = UIColor.theme.grey
        label.textColor = .white
        label.font = UIFont(name: "Times New Roman", size: 16)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.alpha = 1
        label.textAlignment = .center
        parentView.addSubview(label)
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            UIView.animate(withDuration: 0.5) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }

        
    }
    
    
    // MARK: - Keyboard Events
    @objc func keyboardWillHide() {
        scrollViewOutlet.contentInset.bottom = 0
        scrollViewOutlet.scrollIndicatorInsets.bottom = 0
    }
    
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewOutlet.contentInset.bottom = keyboardSize.height
            scrollViewOutlet.scrollIndicatorInsets.bottom = keyboardSize.height
        }
    }

}




protocol keyboardActionDelegate {
    func appendText(text: String)
    func enterPressed()
    func backspacePressed()
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

