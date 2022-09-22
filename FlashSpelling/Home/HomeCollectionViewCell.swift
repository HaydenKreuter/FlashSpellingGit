//
//  HomeCollectionViewCell.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/3/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    // shows the user created lists on the main menu
    @IBOutlet weak var nameLabelOutlet: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var testDateLabel: UILabel!
    
    
    // preview of the first 7 words in the list
    @IBOutlet weak var word1: UILabel!
    @IBOutlet weak var word2: UILabel!
    @IBOutlet weak var word3: UILabel!
    @IBOutlet weak var word4: UILabel!
    @IBOutlet weak var word5: UILabel!
    @IBOutlet weak var word6: UILabel!
    @IBOutlet weak var word7: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
}


