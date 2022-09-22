//
//  PracticeEndViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/28/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class PracticeEndViewController: UIViewController {
    @IBOutlet weak var wordsStudiedOutlet: UILabel!
    @IBOutlet weak var masteryImprovementOutlet: UILabel!
    @IBOutlet weak var totalMasteryOutlet: UILabel!
    @IBOutlet weak var dialogLabelOutlet: UILabel!
    
    @IBOutlet weak var buttonOneOutlet: defaultButton!
    @IBOutlet weak var buttonTwoOutlet: defaultButton!
    @IBOutlet weak var startPracticeTest: defaultButton!
    
    var selectedList: WordList!
    var enablePracticeTest: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wordsStudied = String(selectedList.entity.dayWordsPracticed)
        wordsStudiedOutlet.text = wordsStudied
        navigationItem.hidesBackButton = true
    
        let totalMastery = selectedList.entity.calculateMastery()
        totalMasteryOutlet.text = "\(Double(round(10 * (totalMastery * 100)) / 10) )%"
        
        let masteryImprovement = totalMastery - selectedList.entity.dayStartMastery
        if masteryImprovement > 0 {
            masteryImprovementOutlet.text = "+\(Double(round(10 * (masteryImprovement * 100)) / 10) )%"
        } else {
            masteryImprovementOutlet.text = "0"
        }
        var dialogText = ""
        
        if selectedList.entity.dayWordsPracticed > selectedList.wordsArray.count * 2 {
            dialogText = "Wow, it looks like you've been working really hard today! "
        }
        if masteryImprovement > 0.25 || totalMastery > 0.95 {
            dialogText += "You've made a lot of improvement today, which is fantastic! "
        }
        
        buttonOneOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonOneOutlet.titleLabel?.lineBreakMode = .byClipping
        buttonOneOutlet.titleLabel?.minimumScaleFactor = 0.5
        buttonOneOutlet.titleLabel?.numberOfLines = 2
        
        buttonTwoOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonTwoOutlet.titleLabel?.lineBreakMode = .byClipping
        buttonTwoOutlet.titleLabel?.minimumScaleFactor = 0.5
        buttonTwoOutlet.titleLabel?.numberOfLines = 2
        
        startPracticeTest.titleLabel?.adjustsFontSizeToFitWidth = true
        startPracticeTest.titleLabel?.lineBreakMode = .byClipping
        startPracticeTest.titleLabel?.minimumScaleFactor = 0.5
        startPracticeTest.titleLabel?.numberOfLines = 2
        
        if selectedList.entity.testDate != nil {
            let daysFromTest = selectedList.entity.testDate!.timeIntervalSinceNow / 86400
            if daysFromTest < 1 {
                if totalMastery >= 0.95 {
                    dialogText += "It looks like you should be ready for your test! I would recommend taking a practice test by selecting the 'Start Practice Test' button below."
                } else {
                    dialogText += "I would recommend practicing some more today so you'll be ready for your test coming up. Click the 'Continue Practicing' button below to keep practicing with me."
                }

            } else if daysFromTest < 2 {
                
                if totalMastery >= 0.85 {
                    dialogText += "It looks like you are on track for your test, great job! I would recommend taking a practice test by selecting the 'Start Practice Test' button below."
                    
                } else {
                    dialogText += "I would recommend practicing some more today so you'll be ready for your test coming up. Click the 'Continue Practicing' button below to keep practicing with me"
                    
                }
    
            } else if daysFromTest < 3 {
                if totalMastery >= 0.65 {
                    dialogText += "It looks like you are on track for your test, great job! Come back sometime before your test so we can finish mastering this list!"
                } else {
                    dialogText += "I would recommend practicing some more today so you'll be ready for your test coming up. Click the 'Continue Practicing' button below to keep practicing with me"
                }
                
            } else {
                if totalMastery > 0.45 {
                    dialogText += "It looks like you are on track for your test, great job! Come back soon so we can keep learning these words!"
                }
                
            }
        }
        
        if totalMastery < 65 && dialogText == "" {
            if selectedList.entity.dayWordsPracticed < selectedList.wordsArray.count {
                dialogText = "You are doing great so far but let's keep going! I know you can master this list with some more practice! Click the 'Continue Practicing' button below to keep practicing with me, or select 'Exit Practice' to exit and we can continue practicing later. "
            } else if masteryImprovement < 0.05{
                dialogText = "I know this is a hard list, but if you keep practicing with me I promise it will get easier. You've got this! Click the 'Continue Practicing' button below to keep practicing with me, or select 'Exit Practice' to exit and we can continue practicing later."
            }
        }

        if dialogText == "" {
            dialogText = "I hope you are having a good day! Here is your spelling progress for the day."
        }
        
        
        
        
        dialogLabelOutlet.text = dialogText
        
    }
    
    @IBAction func exitPracticePressed(_ sender: defaultButton) {
        navigationController?.popToViewController(navigationController?.viewControllers[1] as! SpellingListViewController, animated: true)
    }
    
    @IBAction func continuePracticing(_ sender: defaultButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startPracticeTest(_ sender: defaultButton) {
        if let spellingListViewController = navigationController?.viewControllers[1] as? SpellingListViewController {
            spellingListViewController.startTest = true
        }
        navigationController?.popToViewController(navigationController?.viewControllers[1] as! SpellingListViewController, animated: true)
    }
    
    
    
}
