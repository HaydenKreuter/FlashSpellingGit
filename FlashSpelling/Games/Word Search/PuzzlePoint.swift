//
//  PuzzlePoint.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/24/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
struct PuzzlePoint: Hashable {
    var x: Int!
    var y: Int!
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func == (leftPoint: PuzzlePoint, rightPoint: PuzzlePoint) -> Bool {
        return (leftPoint.x == rightPoint.x && leftPoint.y == rightPoint.y)
     }
    
    func getNextPoint(inDirection: WordDirection, stepper: Int = 1) -> PuzzlePoint {
        switch inDirection {
        case .up:
            return PuzzlePoint(x: self.x, y: self.y + stepper)
        case .down:
            return PuzzlePoint(x: self.x, y: self.y - stepper)
        case .right:
            return PuzzlePoint(x: self.x + stepper, y: self.y)
        case .left:
            return PuzzlePoint(x: self.x - stepper, y: self.y)
        case .diagnanalUpRight:
            return PuzzlePoint(x: self.x + stepper, y: self.y + stepper)
        case .diagnanalUpLeft:
            return PuzzlePoint(x: self.x - stepper, y: self.y + stepper)
        case .diagnanalDownRight:
            return PuzzlePoint(x: self.x + stepper, y: self.y - stepper)
        case .diagnanalDownLeft:
            return PuzzlePoint(x: self.x - stepper, y: self.y - stepper)
        }
    }
    
    func isInGrid(gridSize: Int) -> Bool {
        if (0...gridSize - 1) ~= Int(self.x) && (0...gridSize - 1) ~= Int(self.y) {
            return true
        } else {
            return false
        }
    }
    
    func wordAtPoint(wordsInPuzzle: [WordInPuzzle]) -> WordInPuzzle? {
        for word in wordsInPuzzle {
            if word.wordOccupiesPoint(point: self) {
                return word
            }
        }
        return nil
    }
    
}
