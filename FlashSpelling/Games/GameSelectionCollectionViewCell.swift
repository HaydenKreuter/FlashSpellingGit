//
//  GameSelectionCollectionViewCell.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/5/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class GameSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameCoverImageOutlet: UIImageView!
    @IBOutlet weak var gameLabelOutlet: UILabel!
    @IBOutlet weak var overlayViewOutlet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
}
