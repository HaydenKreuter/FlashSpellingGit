//
//  MultipleChoiceView.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 4/10/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class MultipleChoiceView: UIView {
    
    // MARK: - Variables
    var wordText: String!
    var wordOptions: [String]!
    var numberOfOptions: Int = 4
    var buttons: [UIButton] = []
    var vStack: UIStackView!
    var topLabel: UILabel!
    var wordTextField: UITextField!
    var enterButton: UIButton!
    var numberOfAttempts: Int = 0
    
    var delegate: multipleChoiceViewDelegate!
    
    
    //MARK: - Initialization
    init(frame: CGRect, word: WordEntity) {
        super.init(frame: frame)
        
        self.wordText = word.wordName!
        self.wordOptions = []
        
        var allPossibleSubstitutions: [SubstitutionItem] = []
        allPossibleSubstitutions += doubleLetterSubstitution(wordText)
        allPossibleSubstitutions += patternBasedSubstitution(wordText)
 
        allPossibleSubstitutions.shuffle()

        for _ in 1...numberOfOptions {
            if let selectedSubstituion = allPossibleSubstitutions.popLast() {
                let wordOption = wordText.replaceString(start: selectedSubstituion.index, end: selectedSubstituion.index + selectedSubstituion.textToReplace.count - 1, newText: selectedSubstituion.substitutionText)
                wordOptions.append(wordOption)
                
            } else {
                break
            }
        }
        
        wordOptions = Array(Set(wordOptions)) // gets rid of duplicates
        while wordOptions.count < numberOfOptions { // fall back on random substitution
            let randomIndex = (1...wordText.count - 1).randomElement()!
            var wordOption: String!
            let letters = getAlphabet()
            wordOption = wordText.replaceChar(index: randomIndex, letters.randomElement()!)
            wordOptions.append(wordOption)
        }
        wordOptions.append(wordText)
        wordOptions.shuffle()
        
        topLabel = UILabel()
        topLabel.text = "Choose the Correct Spelling"
        topLabel.font = UIFont(name: "Noteworthy", size: 25)
        topLabel.textColor = .white
        topLabel.textAlignment = .center
        self.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        topLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        topLabel.backgroundColor = .theme.grey
        topLabel.layer.masksToBounds = true
        topLabel.layer.cornerRadius = 7
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.minimumScaleFactor = 0.5


        vStack = UIStackView()
        self.addSubview(vStack)
        vStack.axis = .vertical
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 10).isActive = true
        vStack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        vStack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        vStack.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor).isActive = true
        vStack.distribution = .equalSpacing
        vStack.spacing = 15
        
        setUpButtons()
        
    } // init closure
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions
  
    func setUpButtons() {
        for button in buttons {
            button.removeFromSuperview()
        
        }
        buttons.removeAll()
        
        for word in wordOptions {
            let newButton = UIButton()
            newButton.setTitle(word, for: .normal)
            newButton.heightAnchor.constraint(equalToConstant: 65).isActive = true
            newButton.setTitleColor(UIColor.black, for: .normal)
            newButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 30)
         
            newButton.titleLabel?.adjustsFontSizeToFitWidth = true
            newButton.titleLabel?.numberOfLines = 1
            
            newButton.isUserInteractionEnabled = true
            newButton.isSpringLoaded = true
            newButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .highlighted)
            newButton.titleLabel?.textAlignment = .center
            newButton.backgroundColor = .lightText
            newButton.layer.cornerRadius = 12
            newButton.layer.borderWidth = 0
            
            newButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
            
            buttons.append(newButton)
            vStack.addArrangedSubview(newButton)
        }
    }

    
    @objc func checkAnswer(sender: UIButton!) { // checks the answer when a button is pressed
        if sender.titleLabel?.text == wordText { // correct answer
            delegate.playCorrectSound()
            topLabel.text = "Great Job!"
            sender.layer.borderColor = UIColor.green.cgColor
            sender.layer.borderWidth = 7
            for button in buttons {
                if button != sender {
                    UIView.animate(withDuration: 0.5) {
                        button.frame.origin = CGPoint(x: 0, y: self.frame.height + 100)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.25) {
                            button.removeFromSuperview()
                            self.vStack.layoutSubviews()
                        }
                    }
                }
            }
            
            sender.isUserInteractionEnabled = false
            wordTextField = UITextField()
            wordTextField.placeholder = "Enter Word"
            wordTextField.textAlignment = .center
            wordTextField.translatesAutoresizingMaskIntoConstraints = false
            wordTextField.backgroundColor = .lightText
            wordTextField.heightAnchor.constraint(equalToConstant: 65).isActive = true
            wordTextField.isHidden = true
            wordTextField.font = UIFont(name: "Noteworthy", size: 30)
            wordTextField.autocorrectionType = .no
            wordTextField.smartDashesType = .no
            wordTextField.autocapitalizationType = .none
            wordTextField.keyboardType = .webSearch
            wordTextField.layer.cornerRadius = 7
            
            enterButton = defaultButton()
            enterButton.setTitle("Enter", for: .normal)
            enterButton.setTitleColor(.theme.yellow, for: .normal)
            enterButton.backgroundColor = .theme.red
            self.addSubview(enterButton)
            enterButton.translatesAutoresizingMaskIntoConstraints = false
            enterButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
            enterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            enterButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 30)
            enterButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            enterButton.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 15).isActive = true
            enterButton.isHidden = true
            
            enterButton.isSpringLoaded = true
            enterButton.setTitleColor(.theme.tintedYellow, for: .highlighted)
            enterButton.addTarget(self, action: #selector(enterPressed), for: .touchUpInside)
            
            self.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
                vStack.addArrangedSubview(wordTextField)

                wordTextField.addTarget(self, action: #selector(secondaryEnterButton), for: .primaryActionTriggered)
                UIView.animate(withDuration: 0.25) { [self] in
                    wordTextField.isHidden = false
                    enterButton.isHidden = false
                    
                } completion: { [self] _ in
                    wordTextField.becomeFirstResponder()
                    UIView.animate(withDuration: 0.25) { [self] in
                        topLabel.text = "Now type the word: "
                    } completion: { _ in
                        self.isUserInteractionEnabled = true
        
                    }
                }

            })

        } else {
            numberOfAttempts += 1
            topLabel.text = "Sorry, try again"
            sender.layer.borderColor = UIColor.theme.red.cgColor
            sender.layer.borderWidth = 7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                UIView.animate(withDuration: 0.5) {
                    sender.frame.origin = CGPoint(x: 0, y: self.frame.height + 100)
                } completion: { _ in
                    UIView.animate(withDuration: 0.25) {
                        sender.removeFromSuperview()
                        self.vStack.layoutSubviews()
                    }
                }
            })

            self.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.isUserInteractionEnabled = true
            })
            
        }
       
    }
    
    
    
    // MARK: - Enter
    @objc func enterPressed(button: UIButton) {
        onEnter()
    }
    @objc func secondaryEnterButton(textField: UITextField) {
        onEnter()
    }
    
    func onEnter() {
        if wordTextField.text?.lowercased() == wordText.lowercased() {
            delegate.finishedMultipleChoiceEntry(attempts: numberOfAttempts)
        } else {
            topLabel.text = "Enter the correct spelling before continuing"
        }
    }

    
    // MARK: - Substitution Functions
    func doubleLetterSubstitution(_ word: String) -> [SubstitutionItem] {
        var substitutions: [SubstitutionItem] = []
        let alphabet = getAlphabet()
        for l in alphabet {
            let letter = l.lowercased()
            let letterCouple = String(letter) + String(letter)
            let indexes = word.findAllIndexes(letterCouple)
            for index in indexes {
                substitutions.append(SubstitutionItem(index: index, textToReplace: letterCouple, substitutionText: String(letter)))
            }
        }

        return substitutions
    }
    
    
    func patternBasedSubstitution(_ word: String) -> [SubstitutionItem] {
        var possibleSubstitutions: [(Int, Int, [Int])] = [] // pattern location, subpattern location, pattern locations within word
        let patterns: [([String], [String])] = [(["ie", "ei", "ea",], ["e", "i", "ee"]),
                                                (["ent", "ant"], []),
                                                (["ar", "er", "eur"], ["air"]),
                                                (["ery", "ary"], ["airy"]),
                                                (["ely", "ly", "aly", "ally"], []),
                                                (["sc"], ["c", "s"]),
                                                (["os", "ous"], ["us"]),
                                                (["ite", "ate"], []),
                                                (["sy", "cy"], ["y"]),
                                                (["ence", "ance"], ["ants"]),
                                                (["fahr", "far"], []),
                                                (["iar", "ar"], []),
                                                (["fluor", "flor", "four"], []),
                                                (["fore", "for"], []),
                                                (["mor", "mour"], []),
                                                (["gua", "gau"], []),
                                                (["ened", "end", "and"], []),
                                                (["nor", "nour"], []),
                                                (["asy", "acy"], []),
                                                (["ible", "able", "eble"], []),
                                                (["cly", "clly"], []),
                                                (["gious", "gous", "geous", "gaous"], []),
                                                (["se", "es",], ["c"]),
                                                (["par", "per", "pair"], []),
                                                (["sede", "cede", "ced", "seed"], []),
                                                (["sur", "su"], []),
                                                (["wh"], ["w"]),
                                                (["th"], ["t"]),
                                                (["e", "i"], []),
                                                (["o", "u"], [])
                            
        ]
        
        for (patternIndex, pattern) in patterns.enumerated() {
            for (subPatternIndex, subPatern) in pattern.0.enumerated() {
                let patternLocationsWithinWord = word.findAllIndexes(subPatern)
                if !patternLocationsWithinWord.isEmpty {
                    possibleSubstitutions.append((patternIndex, subPatternIndex, patternLocationsWithinWord))
                }
            }
        }
        
        var allSubstitutions: [SubstitutionItem] = []
        for substitution in possibleSubstitutions {
            for patternLocation in substitution.2 {
                let substitutionTextOptions: [String] = patterns[substitution.0].0 + patterns[substitution.0].1
                for option in substitutionTextOptions {
                    if option != (patterns[substitution.0].0)[substitution.1] {
                        allSubstitutions.append(SubstitutionItem(index: patternLocation, textToReplace: (patterns[substitution.0].0)[substitution.1], substitutionText: option))
                    }
                }
            }
        }
        

        return allSubstitutions
    }
    
}


struct SubstitutionItem {
    var index: Int!
    var textToReplace: String!
    var substitutionText: String!
    init(index: Int, textToReplace: String, substitutionText: String) {
        self.index = index
        self.substitutionText = substitutionText
        self.textToReplace = textToReplace
        
    }
}

protocol multipleChoiceViewDelegate {
    func finishedMultipleChoiceEntry(attempts: Int)
    func playCorrectSound()
}
