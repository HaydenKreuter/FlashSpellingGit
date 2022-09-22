//
//  StatAndTestViewController.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 7/26/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class StatAndTestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var selectedList: WordList!
    var historyArray: [TestHistoryEntity] = []
    var selectedHistoryItem: Int = 0
    var listMastery: Double!
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var wordsStudiedOutlet: UILabel!
    @IBOutlet weak var listMasteryOutlet: UILabel!
    @IBOutlet weak var troubleWordsOutlet: UILabel!
    @IBOutlet weak var improvementFromBaselineOutlet: UILabel!
    @IBOutlet weak var testHistoryLabel: UILabel!
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testHistoryCell") as! TestHistoryTableViewCell
        
        let historyItem = historyArray[indexPath.item]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let formatedDate = formatter.string(from: historyItem.date!)
        
        cell.dateLabel.text = "Test Taken on: \(formatedDate)"
        cell.scoreLabel.text = "Score: \(historyItem.score)"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedHistoryItem = indexPath.item
        performSegue(withIdentifier: "showTestItem", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        historyArray = selectedList.entity.testHistory!.allObjects as! [TestHistoryEntity]
        tableViewOutlet.rowHeight = 35
        
        //identify trouble words
        var troubleWords: String = ""
        let words = selectedList.wordsArray!
        let deviaiton = (listMastery * 100) - (standardDeviation(arr: words.map {$0.mastery}))
        
        for word in words {
            if word.mastery < deviaiton {
                if troubleWords == "" {
                    troubleWords = word.wordName!
                } else {
                    troubleWords += ", \(word.wordName!)"
                }
                
            }
        }
        if historyArray.isEmpty {
            testHistoryLabel.text = "Test History\nAfter you take a test, you can view your scores below."
        } else {
            testHistoryLabel.text = "Test History"
        }
        
        wordsStudiedOutlet.text = "\(selectedList.entity.wordsStudied)"
        let formattedMastery = Double(round(10 * (listMastery * 100)) / 10)
        if formattedMastery >= 75 {
            listMasteryOutlet.textColor = .green
            listMasteryOutlet.shadowColor = .black
            listMasteryOutlet.shadowOffset = CGSize(width: 1, height: 1)
        }
        listMasteryOutlet.text = "\(formattedMastery)%"
        
        if troubleWords.isEmpty {
            troubleWordsOutlet.text = "---"
        } else {
            troubleWordsOutlet.text = troubleWords
        }

        if selectedList.entity.percentImprovement != 0 {
            let formattedImprovement = Double(round(10 * selectedList.entity.percentImprovement) / 10)
            improvementFromBaselineOutlet.text = "\(formattedImprovement) %"
            improvementFromBaselineOutlet.textColor = .green
            improvementFromBaselineOutlet.shadowColor = .black
            improvementFromBaselineOutlet.shadowOffset = CGSize(width: 1, height: 1)
        } else {
            improvementFromBaselineOutlet.text = "---"
            improvementFromBaselineOutlet.textColor = .black
        }
        
        
    }
    
    func standardDeviation(arr : [Double]) -> Double {
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTestItem" {
            let controller = segue.destination as! ViewTestViewController
            controller.pdfData = historyArray[selectedHistoryItem].pdf
        }
    }


}
