//
//  GamesSelectionViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/5/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData

class GamesSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    var context: NSManagedObjectContext!
    var selectedList: WordList!
    let availableGames: [(String, String)] = [("wordSearch", "Word Search"), ("guessThree", "Guess Three"), ("comingSoon", "Coming Soon!")] // [image name: Display name ]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        availableGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GameSelectionCollectionViewCell
        let item = availableGames[indexPath.item]
        cell.gameCoverImageOutlet.image = UIImage(named: item.0)
        cell.gameLabelOutlet.text = item.1
        if item.0 == "comingSoon" {
            cell.isUserInteractionEnabled = false
            cell.overlayViewOutlet.alpha = 0.4

        } else {
            cell.isUserInteractionEnabled = true
            cell.overlayViewOutlet.alpha = 0.0
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            if let currentWordSeach = selectedList.entity.wordSearchPuzzle {
                let alert = UIAlertController(title: "Game In Progress", message: "Would you like to continue the game in progress or start a new game?", preferredStyle: .alert)


                let continueAction = UIAlertAction(title: "Continue Game", style: .default, handler: { [self] _ in
                    performSegue(withIdentifier: "wordSearchSelected", sender: self)
                })
                let newGameAction = UIAlertAction(title: "New Game", style: .default, handler: { [self] _ in
                    context.delete(currentWordSeach)
                    performSegue(withIdentifier: "wordSearchSelected", sender: self)
                })

        
                alert.addAction(continueAction)
                alert.addAction(newGameAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "wordSearchSelected", sender: self)
            }
                                            
        case 1:
            performSegue(withIdentifier: "guessWordSelected", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "wordSearchSelected":
            let controller = segue.destination as! WordSearchViewController
            controller.selectedList = selectedList
        case "guessWordSelected":
            let controller = segue.destination as! WordGuessViewController
            controller.selectedList = selectedList
        default:
            break
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        collectionViewOutlet.setCollectionViewLayout(layout, animated: true)
        
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        
    }


}


