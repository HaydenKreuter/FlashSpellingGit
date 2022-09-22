//
//  TestTableViewCell.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/2/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import AVFoundation


class TestTableViewCell: UITableViewCell {
    
    var delegate: testTableViewCellDelegate!
    var index: Int!
    
    @IBOutlet weak var wordNumberOutlet: UILabel!
    @IBOutlet weak var wordLabelOutlet: UILabel!
    @IBOutlet weak var cellBackgroundOutlet: UIView!
    
    override func awakeFromNib() {
        cellBackgroundOutlet.layer.cornerRadius = 7
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        delegate.editWord(index: index)
        
    }
    

}

protocol testTableViewCellDelegate {
    func editWord(index: Int)
}

