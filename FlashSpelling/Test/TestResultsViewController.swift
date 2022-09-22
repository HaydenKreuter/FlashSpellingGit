//
//  TestResultsViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/9/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import PDFKit

class TestResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var numberCorrectLabel: UILabel!
    @IBOutlet weak var scorePercentageLabelOutlet: UILabel!
    @IBOutlet weak var circularViewOutlet: UIView!

    @IBOutlet weak var navigationBarOutlet: UINavigationItem!
    @IBOutlet weak var wordTableViewOutlet: UITableView!
    @IBOutlet weak var textLabelOutlet: UILabel!
    @IBOutlet weak var flashImageViewOutlet: UIImageView!
    
    @IBOutlet weak var improvementLabel: UILabel!
    
    var context: NSManagedObjectContext!
    
    var wordList: WordList!
    var allWords: [WordEntity] = []
    var wordsEntered: [String] = []
    
    var numberOfWordsCorrect: Int = 0
    var roundedScore: Double!
    var isBaselineTest: Bool!
    
    var audioSession: AVAudioSession!
    
    
    // MARK: - Properties -
    
    var circularProgressBarView: CircularResultWheelView!
    var circularViewDuration: TimeInterval = 1

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarOutlet.hidesBackButton = true
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        // if there is a saved test, delete
        if let testInProgress = wordList.entity.testInProgress {
            context.delete(testInProgress)
        }

        //setting audio session
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            } catch {
            }
        }
        
        for wordIndex in 0...allWords.count - 1 {
            let levenshteinCalculation = levenshteinDistance(wordOne: allWords[wordIndex].wordName!, wordTwo: (wordsEntered[wordIndex]))
            
            // update mastery
            
            if isBaselineTest {
                if levenshteinCalculation == 0 { //correct
                    allWords[wordIndex].mastery = 70
                    numberOfWordsCorrect += 1
                } else {
                    var ratio: Double = Double(levenshteinCalculation) / Double(allWords[wordIndex].wordName!.count)
                    if ratio > 1 {
                        ratio = 1
                    }
                    var update = -ratio * 50
                    if update < -15 {
                        update = -15
                    }
                    allWords[wordIndex].mastery = 35 + update
                }
            } else {
                if levenshteinCalculation == 0 { //correct
                    allWords[wordIndex].updateMastery(35)
                    numberOfWordsCorrect += 1
                } else {
                    var ratio: Double = Double(levenshteinCalculation) / Double(allWords[wordIndex].wordName!.count)
                    if ratio > 1 {
                        ratio = 1
                    }
                    var update = -ratio * 50
                    if update < -15 {
                        update = -15
                    }
                    allWords[wordIndex].updateMastery(update)
                }
            }
        }
    
        
        numberCorrectLabel.text = "\(numberOfWordsCorrect) / \(allWords.count)"
        let percentCorrect: Double = (Double(numberOfWordsCorrect) / Double(allWords.count)) * 100
        roundedScore = Double(round(10 * percentCorrect) / 10)
        scorePercentageLabelOutlet.text = String(roundedScore)
        wordList.entity.wordsStudied += Int16(allWords.count)
        wordList.entity.updateDayWordsStudied(allWords.count)
        if isBaselineTest {
            wordList.entity.baselineTestScore = percentCorrect
        }
        do {
            try context.save()
        } catch {
            
        }
        
        if isBaselineTest {
            switch percentCorrect {
            case 0...25:
                textLabelOutlet.text = "Wow this looks like a hard list! Don't worry though, I can help you learn these words in no time!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 25...50:
                textLabelOutlet.text = "It looks like you already know some of these! With a little bit of practice you'll be able to master this list!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 50...75:
                textLabelOutlet.text = "Wow! You know most of these already! We will work on the ones you don't know so you can do great on your test!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 75...99:
                textLabelOutlet.text = "Great job! It looks like you know almost all of these! With a little bit of practice I can help you ace your test!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 100:
                textLabelOutlet.text = "Wow! It looks like you already know all these. You'll be ready for your test in no time."
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            default:
                break
            }
        } else {
            switch percentCorrect {
            case 0...25:
                textLabelOutlet.text = "Wow this looks like a hard list! Don't worry though, I can help you learn these words in no time!"
                flashImageViewOutlet.image = UIImage(named: "sadFlash")
            case 25...50:
                flashImageViewOutlet.image = UIImage(named: "sadFlash")
                textLabelOutlet.text = "Great try! I recommend using learn mode to help you learn the rest of these."
            case 50...75:
                textLabelOutlet.text = "It looks like you're making great progress on this list!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 75...99:
                textLabelOutlet.text = "Great job! You're so close to mastering this list!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            case 100:
                textLabelOutlet.text = "Perfect!!"
                flashImageViewOutlet.image = UIImage(named: "happyFlash")
            default:
                break
            }
        }
        
        if wordList.entity.baselineTestScore == -1 {
            wordList.entity.baselineTestScore = percentCorrect
        } else {
            if wordList.entity.baselineTestScore < percentCorrect {
                let percentImprovement = ((percentCorrect - wordList.entity.baselineTestScore) / wordList.entity.baselineTestScore) * 100
                improvementLabel.text = "Wow! That's a \(Double(round(10 * percentImprovement) / 10)) % improvement!"
                if wordList.entity.percentImprovement < percentImprovement {
                    wordList.entity.percentImprovement = percentImprovement
                }
            }
        }
        
        let testHistoryItem = TestHistoryEntity(context: context)
        testHistoryItem.date = Date()
        testHistoryItem.score = roundedScore
        testHistoryItem.pdf = createPDF()
        testHistoryItem.wordListEntity = wordList.entity
        
        do {
            try context.save()
        } catch {
            print("no save")
        }
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        circularProgressBarView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpCircularProgressBarView(scoreRatio: (Double(numberOfWordsCorrect) / Double(allWords.count)))
        UIView.animate(withDuration: 0.25) { [self] in
            self.circularProgressBarView.alpha = 1
        }
        if (Double(numberOfWordsCorrect)  / Double(allWords.count)) > 0.85 {
            let confettiController = confettiController(parentView: view)
            view.layer.addSublayer(confettiController.confettiLayer)

        }
        
    }
    
    // MARK: -
    
    func levenshteinDistance(wordOne: String, wordTwo: String) -> Int {
        let empty = [Int](repeating:0, count: wordTwo.count)
        var last = [Int](0...wordTwo.count)

        for (i, char1) in wordOne.enumerated() {
            var current = [i + 1] + empty
            for (j, char2) in wordTwo.enumerated() {
                current[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        return last.last!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wordTableViewOutlet.dequeueReusableCell(withIdentifier: "testResultCell") as! TestResultsTableViewCell
        cell.wordnumberLabelOutlet.text = "\(indexPath.item + 1)"
        
        if allWords[indexPath.item].wordName == wordsEntered[indexPath.item] {
            cell.checkMarkImageViewOutlet.image = UIImage(named: "CheckMark")
            cell.wordLabelOutlet.text = wordsEntered[indexPath.item]

        } else {
            cell.checkMarkImageViewOutlet.image = UIImage(named: "XMark")
            cell.wordLabelOutlet.text = "\(wordsEntered[indexPath.item]) (\(allWords[indexPath.item].wordName!))"
        }
        return cell
    }
    
    func setUpCircularProgressBarView(scoreRatio: Double) {
        circularProgressBarView = CircularResultWheelView(frame: .zero, scoreRatio: scoreRatio , parentViewSize: topView.frame.size)

        circularProgressBarView.createCircularPath()
        circularProgressBarView.alpha = 0
        
        circularProgressBarView.progressAnimation(duration: circularViewDuration)

        topView.addSubview(circularProgressBarView)
        circularProgressBarView.translatesAutoresizingMaskIntoConstraints = false
 
        topView.addConstraint(NSLayoutConstraint(item: circularProgressBarView!, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: circularProgressBarView!, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    
    // MARK: - IB Outlet Actions
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        // presents activity controller to ask where to send
        let activityController = UIActivityViewController(activityItems: [createPDF()], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        // this line causing crash in v 1.1 possibly due to opening a test from link
        navigationController?.popToViewController(navigationController?.viewControllers[1] as! SpellingListViewController, animated: true)
        
    }
    
    
    // MARK: - PDF creation for test results
    func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "My Spelling School"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

       
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

    
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
     
            context.beginPage()
            var headingTopPoint: CGFloat = 0
            headingTopPoint = addTitle(pageRect: pageRect, text: wordList.name!.capitalized)
            
            headingTopPoint = addSubTitle(pageRect: pageRect, text: "Test Taken On: \(dateFormatter.string(from: Date()))", topTextPoint: headingTopPoint)
            
            headingTopPoint = addSubTitle(pageRect: pageRect, text: "Score: \(roundedScore!)%", topTextPoint: headingTopPoint)
            headingTopPoint = addSubTitle(pageRect: pageRect, text: "\(numberOfWordsCorrect) out of  \(allWords.count) correct\n", topTextPoint: headingTopPoint)
            
            var xPoint: CGFloat = 50
            var wordTopPoint: CGFloat = headingTopPoint
            
            for index in 0...wordsEntered.count - 1 {
                wordTopPoint = addWord(pageRect: pageRect, wordIndex: index, textPoint: CGPoint(x: xPoint, y: wordTopPoint))
                
                if wordTopPoint > (pageHeight - 80) && xPoint < pageWidth / 2 {
                    xPoint = pageWidth / 2 + 50
                    wordTopPoint = headingTopPoint
                    headingTopPoint = 20
                } else if wordTopPoint > (pageHeight - 80) {
                    context.beginPage()
                    xPoint = 50
                    wordTopPoint = 20
                }
                
                
            }
      }

        return data
    }
    
    func addTitle(pageRect: CGRect, text: String) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 50)!,
        ]
        
        let attributedTitle = NSAttributedString(string: text, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 15,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        attributedTitle.draw(in: titleStringRect)
        
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    
    func addSubTitle(pageRect: CGRect, text: String, topTextPoint: CGFloat) -> CGFloat {
        let subTitleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 30)!,
            
        ]
 
        let attributedTitle = NSAttributedString(string: text, attributes: subTitleAttributes)
        let subTitleStringSize = attributedTitle.size()
        
        let subTitleStringRect = CGRect(
            x: (pageRect.width - subTitleStringSize.width) / 2.0,
            y: topTextPoint,
            width: subTitleStringSize.width,
            height: subTitleStringSize.height
        )
        attributedTitle.draw(in: subTitleStringRect)
        
        return subTitleStringRect.origin.y + subTitleStringRect.size.height
    }
    
    func addWord(pageRect: CGRect, wordIndex: Int, textPoint: CGPoint) -> CGFloat {
        
        let labelWordAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 14)!
        ]
        
        let correctWordAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 14)!,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.green
        ]
        
        let incorrectWordAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 14)!,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.red
        ]
        
        let attributedWordNumber = NSAttributedString(string: "\(wordIndex + 1).", attributes: labelWordAttributes)
        let attributedWordNumberSize = attributedWordNumber.size()
        
        let attributedWordLabel = NSAttributedString(string: "\(allWords[wordIndex].wordName!.capitalized)", attributes: labelWordAttributes)
        let attributedWordLabelSize = attributedWordLabel.size()
        
        var attributedWordEntered: NSAttributedString!
        
        if (allWords[wordIndex].wordName! == wordsEntered[wordIndex]) {
            attributedWordEntered = NSAttributedString(string: wordsEntered[wordIndex].capitalized, attributes: correctWordAttributes)
        } else {
            attributedWordEntered = NSAttributedString(string: wordsEntered[wordIndex].capitalized, attributes: incorrectWordAttributes)
        }
        let attributedWordEnteredSize = attributedWordLabel.size()
        
        let numberStirngRect = CGRect(
            x: textPoint.x,
            y: textPoint.y,
            width: attributedWordNumberSize.width,
            height: attributedWordNumberSize.height
        )
        attributedWordNumber.draw(in: numberStirngRect)
        
        let labelStringRect = CGRect(
            x: textPoint.x + 30,
            y: textPoint.y,
            width: attributedWordLabelSize.width,
            height: attributedWordLabelSize.height
        )
        attributedWordLabel.draw(in: labelStringRect)
        
        let wordEnteredStringRect = CGRect(
            x: textPoint.x + pageRect.width / 4,
            y: textPoint.y,
            width: attributedWordEnteredSize.width,
            height: attributedWordEnteredSize.height
        )
        attributedWordEntered.draw(in: wordEnteredStringRect)
        
        
        return labelStringRect.origin.y + labelStringRect.size.height
    }
    
}

