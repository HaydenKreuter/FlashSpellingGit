//
//  WordsFoundCollectionViewCell.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/13/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class WordsFoundCollectionViewCell: UICollectionViewCell {
    static var identifier: String = "wordsFoundCell"
    weak var wordLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let wordLabel = UILabel(frame: .zero)
        self.contentView.addSubview(wordLabel)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        wordLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        wordLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        wordLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        wordLabel.font = UIFont(name: "Noteworthy", size: 25)
        wordLabel.adjustsFontSizeToFitWidth = true
        wordLabel.minimumScaleFactor = 0.1
        wordLabel.textAlignment = .center
        wordLabel.textColor = .theme.blue
        self.wordLabel = wordLabel
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}
