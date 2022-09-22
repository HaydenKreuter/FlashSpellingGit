//
//  ViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/16/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit

class AddWordsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordNumberLabel: UILabel!
    @IBOutlet weak var colorBackgroundView: UIView!
    
    var delegate: addWordCellDelegate!
    var index: Int!
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate.editWord(index: index)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate.deleteWord(index: index, effect: 2)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorBackgroundView.layer.cornerRadius = 7
    }
}


protocol addWordCellDelegate {
    func deleteWord(index: Int, effect: Int)
    func editWord(index: Int)
}
