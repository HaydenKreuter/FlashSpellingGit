//
//  File.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/26/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
import UIKit

class TextStackView: UIStackView, UIKeyInput {
    var autocorrectionType: UITextAutocorrectionType = .no
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var smartInsertDeleteType: UITextSmartInsertDeleteType = .no
    var spellCheckingType: UITextSpellCheckingType = .no

    var hasText: Bool = false
    var delegate: keyboardActionDelegate!
    
    var letterTiles: [UILabel] = []
    
    
    func insertText(_ text: String) {
        if text == "\n" {
            delegate.enterPressed()
        } else {
            delegate.appendText(text: text)
        }
        
    }
    
    func deleteBackward() {
        delegate.backspacePressed()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    
    
    init(selectedWord: String, spacing: CGFloat) {
        super.init(frame: .null)
        for _ in 1...selectedWord.count {
            
            let label = UILabel()
            label.font = UIFont(name: "Noteworthy", size: 30)
            label.layer.borderWidth = 2
            label.textAlignment = .center
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 7
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 0
            label.lineBreakMode = .byClipping
            label.minimumScaleFactor = 0.1
            
            self.letterTiles.append(label)
            self.addArrangedSubview(label)
            self.spacing = spacing
            self.distribution = .fillEqually
            
        }
        
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
}
