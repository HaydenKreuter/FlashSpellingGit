//
//  viewItemTableViewCell.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/18/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit

class SpellingItemTableViewCell: UITableViewCell {

    @IBOutlet weak var countLabelOutlet: UILabel!
    @IBOutlet weak var primaryLabelOutlet: UILabel!
    @IBOutlet weak var backgroundColorViewOutlet: UIView!
    
    @IBOutlet weak var starStackOutlet: UIStackView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColorViewOutlet.layer.cornerRadius = 7
        for _ in 1...5 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .theme.yellow
            starStackOutlet.addArrangedSubview(imageView)
        }
        
    
        
   
    }


}
