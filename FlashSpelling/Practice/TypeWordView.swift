//
//  TypeWordView.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 4/11/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import AVFoundation

class TypeWordView: UIView {
    
    // MARK: - Variables
    var topLabel: UILabel!
    var word: WordEntity!
    var wordTextField: UITextField!
    var enterButton: UIButton!
    var vStack: UIStackView!
    var redemptionActive: Bool = false
    var firstTryDistance: Int!
    
    var delegate: typeWordViewDelegate!
    
    init(frame: CGRect, word: WordEntity) {
        super.init(frame: frame)
        
        self.word = word
        topLabel = UILabel()
        topLabel.text = "Type the word you hear"
        topLabel.font = UIFont(name: "Noteworthy", size: 25)
        topLabel.layer.borderColor = .none
        topLabel.textAlignment = .center
        self.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        topLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        topLabel.backgroundColor = .lightText
        topLabel.layer.masksToBounds = true
        topLabel.layer.cornerRadius = 7
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.minimumScaleFactor = 0.5
        topLabel.numberOfLines = 3
        topLabel.layer.borderWidth = 0
        topLabel.textColor = .black
        
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
        
        
        wordTextField = UITextField()
        wordTextField.placeholder = "Enter Word"
        wordTextField.textAlignment = .center
        wordTextField.backgroundColor = .lightText
        wordTextField.textColor = .black
        wordTextField.translatesAutoresizingMaskIntoConstraints = false
        wordTextField.heightAnchor.constraint(equalToConstant: 65).isActive = true
        wordTextField.font = UIFont(name: "Noteworthy", size: 30)
        wordTextField.autocorrectionType = .no
        wordTextField.smartDashesType = .no
        wordTextField.autocapitalizationType = .none
        wordTextField.keyboardType = .webSearch
        wordTextField.layer.cornerRadius = 7
        wordTextField.becomeFirstResponder()
        wordTextField.addTarget(self, action: #selector(secondaryEnterButton), for: .primaryActionTriggered)
        vStack.addArrangedSubview(wordTextField)

        
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
        enterButton.isSpringLoaded = true
        enterButton.setTitleColor(.theme.tintedYellow, for: .highlighted)
        enterButton.addTarget(self, action: #selector(enterPressed), for: .touchUpInside)
        
       
    }
    

    
    @objc func enterPressed(button: UIButton) {
        onEnter()
        
    }
    @objc func secondaryEnterButton(textField: UITextField) {
        onEnter()
    }
    
    
    
    func onEnter() {
        let levenshteinCalculation = levenshteinDistance(wordOne: word.wordName!.lowercased(), wordTwo: (wordTextField.text?.lowercased())!)
        if levenshteinCalculation >= word.wordName!.count - 1 {
            topLabel.text = "Please try your best before continuing"
            topLabel.layer.borderWidth = 7
            topLabel.layer.borderColor = UIColor.theme.red.cgColor
        } else {
            if firstTryDistance == nil {
                firstTryDistance = levenshteinCalculation
            }
            
            if levenshteinCalculation == 0 {
                delegate.playCorrectSound()
                topLabel.text = "Correct!"
                topLabel.layer.borderWidth = 7
                topLabel.layer.borderColor = UIColor.green.cgColor
                vStack.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [self] in
                    delegate.finishedTextEntry(similarity: firstTryDistance, redemptionActive: redemptionActive)
                    
                })
            } else if levenshteinCalculation == 1 && !redemptionActive {
                topLabel.text = "So close! Try again!"
                topLabel.layer.borderWidth = 7
                topLabel.layer.borderColor = UIColor.theme.yellow.cgColor
                redemptionActive = true
            } else {
                topLabel.layer.borderWidth = 7
                topLabel.layer.borderColor = UIColor.theme.red.cgColor
                topLabel.text = "Please type the word:\(word.wordName!.capitalized)"
            }
             
        }


    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func levenshteinDistance(wordOne: String, wordTwo: String) -> Int {
        let empty = [Int](repeating:0, count: wordTwo.count)
        var last = [Int](0...wordTwo.count)

        for (i, char1) in wordOne.enumerated() {
            var current = [i + 1] + empty
            for (j, char2) in wordTwo.enumerated() {
                current[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        return last.last!
    }
    
    
}


protocol typeWordViewDelegate {
    func finishedTextEntry(similarity: Int, redemptionActive: Bool)
    func playCorrectSound()
}
