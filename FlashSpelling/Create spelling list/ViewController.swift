//
//  ViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/16/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit

class addWordsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordNumberLabel: UILabel!
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


protocol addWordCellDelegate {
    func deleteWord()
    func editWord()
}
