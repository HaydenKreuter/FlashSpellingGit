//
//  Helper.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 4/14/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable public class RoundedView: UIView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
    }
}

@IBDesignable public class defaultButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }


    func setupViews() {
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = .byClipping
        self.titleLabel?.minimumScaleFactor = 0.1
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 7
        
    }

}


extension WordEntity {
    func updateMastery(_ masteryChange: Double) {
        var newMastery = self.mastery + masteryChange
        if newMastery > 100 {
            newMastery = 100
        } else if newMastery < 0 {
             newMastery = 0
        }
        self.mastery = newMastery
        
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [String: Any]()
        dictionary["wordName"] = self.wordName
        dictionary["order"] = self.order
        dictionary["audioRecordingData"] = "0"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        let fileName = documentDirectory.appendingPathComponent(self.recordingPath!)
        
        let data = FileManager.default.contents(atPath: fileName.path)

        if data != nil {
            dictionary["audioRecordingData"] = data!.base64EncodedString()
        }
        
        return dictionary
        
    }
    
}


extension WordListEntity {
    
    func updateDayWordsStudied(_ wordsStudied: Int = 1) {
        if self.dayStartDate == nil || Date() > self.dayStartDate!.addingTimeInterval(86400) { // reset
            self.dayStartDate = Date().addingTimeInterval(-86400 / 2)
            self.dayStartMastery = self.calculateMastery()
            self.dayWordsPracticed = 0
        }
        self.dayWordsPracticed += Int16(wordsStudied)
    }
    
    func calculateMastery() -> Double {
        let words = (self.wordEntity!.allObjects as! [WordEntity])
        let possiblePoints = words.count * 100
        var pointsRecieved: Double = 0.0
        for word in words {
            pointsRecieved += word.mastery
        }
        let totalMastery = (Double(pointsRecieved) / Double(possiblePoints))
        return totalMastery
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [String: Any]()
        dictionary["listName"] = self.listName
        dictionary["testDate"] = self.testDate?.timeIntervalSince1970
        
        var wordsArray: [[String: Any]] = []
        for word in self.wordEntity!.allObjects as! [WordEntity] {
            wordsArray.append(word.toDictionary())
        }
        dictionary["words"] = wordsArray
    
        return dictionary
        
    }
}


extension String {
    func findAllIndexes(_ substring: String) -> [Int] {
        var indexes: [Int] = []
        let wordLetterArray = Array(self)
        let substringArray = Array(substring)
        for wordLetterIndex in 0...wordLetterArray.count - 1 {
            for substringLetterIndex in 0...substringArray.count - 1 {
                if (wordLetterIndex + substringLetterIndex) >= wordLetterArray.count {
                    break
                }
                if wordLetterArray[wordLetterIndex + substringLetterIndex] != substringArray[substringLetterIndex] {
                    break
                }
                if substringLetterIndex == substringArray.count - 1 {
                    indexes.append(wordLetterIndex)
                }
                
            }
            
        }
        return indexes
    }
    
    func replaceString(start: Int, end: Int, newText: String) -> String {
        if self.count > start && self.count > end && end >= 0 && start >= 0 { // validate input
            var wordAsArray = Array(self)
            
            wordAsArray.removeSubrange(start...end)
            wordAsArray.insert(contentsOf: Array(newText), at: start)
            
            return String(wordAsArray)
        } else {
            return self
        }
        
        
    }
    
    
    func replaceChar(index: Int, _ newChar: Character) -> String {
        var chars = Array(self)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}


extension UIColor {
    struct theme {
        static var red: UIColor  { return UIColor(red: 210 / 255, green: 62 / 255, blue: 55 / 255, alpha: 0.9) }
        static var yellow: UIColor { return UIColor(red: 238 / 255, green: 194 / 255, blue: 68 / 255, alpha: 1) }
        static var tintedYellow: UIColor { return UIColor(red: 238 / 255, green: 194 / 255, blue: 68 / 255, alpha: 0.5) }
        static var white: UIColor { return UIColor(red: 235 / 255, green: 231 / 255, blue: 196 / 255, alpha: 0.9) }
        static var blue: UIColor { return UIColor(red: 125 / 255, green: 192 / 255, blue: 179 / 255, alpha: 0.9) }
        static var grey: UIColor { return UIColor(red: 60 / 255, green: 65 / 255, blue: 85 / 255, alpha: 0.9) }
  }
}


enum difficulty: Int {
    case easy = 0
    case medium = 1
    case hard = 2
}

enum WordDirection: Int {
    case up = 0
    case down = 1
    case right = 3
    case left = 4
    case diagnanalUpRight = 5
    case diagnanalUpLeft = 6
    case diagnanalDownRight = 7
    case diagnanalDownLeft = 8
}


func getAlphabet() -> [Character] {
    let aScalars = "a".unicodeScalars
    let aCode = aScalars[aScalars.startIndex].value

    return (0..<26).map {
        i in Character(UnicodeScalar(aCode + i)!)
    }
}


extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
}

extension Date {

    func toString(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)

        return str
    }
}
