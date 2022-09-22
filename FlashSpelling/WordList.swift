//
//  WordList.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 4/23/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
struct WordList {
    var name: String! // name of the set defined by the user
    var dateCreated: Date! // date of creation
    var testDate: Date? // option test date defined by the user
    var entity: WordListEntity! // parent entity of set
    var wordsArray: [WordEntity]! // list of words
     
    init(name: String!, dateCreated: Date!, testDate: Date?, category: Int!, entity: WordListEntity!, wordsArray: [WordEntity]) {
         self.name = name
         self.dateCreated = dateCreated
         self.testDate = testDate
         self.entity = entity
         self.wordsArray = wordsArray
        

    }
}


