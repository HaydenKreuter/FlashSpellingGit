//
//  WordInPuzzle.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/24/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
struct WordInPuzzle: Hashable {
    var wordEntity: WordEntity
    var orginPoint: PuzzlePoint!
    var direction: WordDirection
    
    
    init(word: WordEntity) {
        self.wordEntity = word
        self.orginPoint = PuzzlePoint(x: Int(word.wordPosition!.x), y: Int(word.wordPosition!.y))
        self.direction = WordDirection(rawValue: Int(word.wordPosition!.direction))!
    }
    
    static func == (leftWord: WordInPuzzle, rightWord: WordInPuzzle) -> Bool {
        return (leftWord.wordEntity == rightWord.wordEntity)
     }
    
    func wordOccupiesPoint(point: PuzzlePoint) -> Bool {
        var allPointsInWord: [PuzzlePoint] {
            var tempPoints: [PuzzlePoint] = [self.orginPoint]
            for _ in 1...self.wordEntity.wordName!.count - 1 {
                tempPoints.append((tempPoints.last?.getNextPoint(inDirection: self.direction))!)
                
            }
            return tempPoints
        }
        return allPointsInWord.contains(point)
    }

}
