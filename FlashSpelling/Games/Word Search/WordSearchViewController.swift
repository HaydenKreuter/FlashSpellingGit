//
//  CrosswordViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 5/5/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class WordSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, gameEndingPopupDelegate {
    let gridSizes: [Int: Int] = [0: 12, 1: 15, 2: 20] // size: row count
    var difficultyMode: difficulty!
    var wordsFound: [WordInPuzzle] = []
    var selectedList: WordList!
    let verticalStack = UIStackView()
    var collectionView: UICollectionView!
    var context: NSManagedObjectContext!
    var loadingSpinner: LoadingSpinnerViewController!
    
    
    var currentSelection:Set<PuzzlePoint> = []
    var gridSize: Int = 0
    var labelArray: [[UILabel]] =  []
    var wordsInPuzzle: [WordInPuzzle] = []
    var wordSearchPuzzleEntity: WordSearchPuzzleEntity!
    
    var touchStartPosition: CGPoint?
    
    
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    var playButtonController: PlayButtonController!

    
    // MARK: - IB Outlets
    @IBOutlet weak var navigationItemOutlet: UINavigationItem!
    @IBOutlet weak var playButtonOutlet: UIBarButtonItem!
    
    
    // MARK: - IB Outlet Actions
    @IBAction func saveAndExitButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try context.save()
        } catch {
            
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func printButtonPressed(_ sender: UIBarButtonItem) {
        var lettersTwoDim: [[String]] = []
        var lettersOneDim: [Character] = Array(layoutAsString().reversed())
        for _ in 0...gridSize - 1 {
            var tempArray: [String] = []
            for _ in 0...gridSize - 1 {
                tempArray.append(String(lettersOneDim.popLast()!))
            }
            lettersTwoDim.append(tempArray)
        }
        
        
        // presents activity controller to ask where to send
        let activityController = UIActivityViewController(activityItems: [createPDF(letters: lettersTwoDim)], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = sender
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        playRandomWord()
    }
    
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsFound.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordsFoundCollectionViewCell.identifier.self, for: indexPath) as! WordsFoundCollectionViewCell
        cell.wordLabel.text = Array(wordsFound)[indexPath.item].wordEntity.wordName
        return cell
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up core data
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.context
        
        navigationItemOutlet.hidesBackButton = true
        
        playButtonController = PlayButtonController(audioPlayer: audioPlayer, barButton: playButtonOutlet)
        
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            } catch {
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        view.addSubview(verticalStack)
        if !wordsInPuzzle.isEmpty {
            return
        }
        if let currentPuzzle = selectedList.entity.wordSearchPuzzle { // puzzle in progress
            gridSize = Int(currentPuzzle.lettersInrow)
            setUpStackView(screenSize: view.frame.size)
            layoutLettersFromString(letters: currentPuzzle.crosswordLetters!)
            wordSearchPuzzleEntity = currentPuzzle
            for word in Array(currentPuzzle.wordsInPuzzle!) as! [WordEntity] {
                wordsInPuzzle.append(WordInPuzzle(word: word))
            }
            
            for word in Array(currentPuzzle.wordFound!) as! [WordEntity] {
                let wordFound = WordInPuzzle(word: word)
                wordsFound.append(wordFound)
                var wordPoint = wordFound.orginPoint!
                let wordDirection = wordFound.direction
                labelArray[wordPoint.y][wordPoint.x].backgroundColor = .theme.blue //
                for _ in 2...word.wordName!.count {
                    wordPoint = wordPoint.getNextPoint(inDirection: wordDirection)
                    labelArray[wordPoint.y][wordPoint.x].backgroundColor = .theme.blue //
                }
                
            }
            navigationItemOutlet.title = "\(wordsFound.count) / \(wordsInPuzzle.count)"
        } else { // new word search
            // show loading spinner
            loadingSpinner = LoadingSpinnerViewController()
            addChild(loadingSpinner)
            loadingSpinner.view.frame = view.frame
            view.addSubview(loadingSpinner.view)
            loadingSpinner.didMove(toParent: self)
            
            wordSearchPuzzleEntity = WordSearchPuzzleEntity(context: context)
            wordSearchPuzzleEntity.wordList = selectedList.entity
            let alert = UIAlertController(title: "Select Puzzle Size:", message: "", preferredStyle: .alert)

            let easyAction = UIAlertAction(title: "Small", style: .default, handler: { [self] _ in
                difficultyMode = .easy
                setUpNewWordSearch()
                
            })
            let mediumAction = UIAlertAction(title: "Medium", style: .default, handler: { [self] _ in
                difficultyMode = .medium
                setUpNewWordSearch()
            })
            let hardAction = UIAlertAction(title: "Large", style: .default, handler: { [self] _ in
                difficultyMode = .hard
                setUpNewWordSearch()

            })
            alert.addAction(easyAction)
            alert.addAction(mediumAction)
            alert.addAction(hardAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func exitPressed() {
        navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Touch Cycle
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let initialTouchLocation: CGPoint = (touches.first?.location(in: view))!

            for labelRow in labelArray {
                for label in labelRow {
                    if touchInView(touchLocation: initialTouchLocation, view: label) {
                        let adjustedStartPoint = CGPoint(x: (label.globalFrame?.origin.x)! + label.frame.width / 2, y: (label.globalFrame?.origin.y)! + label.frame.height / 2)
                        touchStartPosition = adjustedStartPoint
                        
                    }
                }
            }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let lastTouchPoint = touches.first?.location(in: view)
        if touchInView(touchLocation: lastTouchPoint!, view: self.verticalStack) {
            if let orgin = touchStartPosition {
                
                let touchSnapToPoint = approximateLineToAxis(orgin: orgin, endPoint: lastTouchPoint!)
                selectLetterAlongLine(startPoint: orgin, endPointLocal: touchSnapToPoint)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        checkIfWordFound()
        currentSelection.removeAll()
        touchStartPosition = nil
    }
    
    // MARK: - Functions
    
    func setUpNewWordSearch() {
        setUpStackView(screenSize: view.frame.size)
        layoutWords(allWords: selectedList.wordsArray)
        layoutRandomLetters(lettersToChooseFrom: getAlphabet())
        wordSearchPuzzleEntity.crosswordLetters = layoutAsString()
        navigationItemOutlet.title = "\(wordsFound.count) / \(wordsInPuzzle.count)"
        
        loadingSpinner.willMove(toParent: nil)
        loadingSpinner.view.removeFromSuperview()
        loadingSpinner.removeFromParent()
    }
    
    func playRandomWord() {
        let remainingWords: [WordInPuzzle] = {
            var tempArray: [WordInPuzzle] = []
            for word in wordsInPuzzle {
                if !wordsFound.contains(word) {
                    tempArray.append(word)
                }
            }
            return tempArray
        }()
    
        if let randomSelection = remainingWords.randomElement()?.wordEntity {
            playButtonController.play(path: randomSelection.recordingPath!, word: randomSelection.wordName!)
        }
    }

    
    func checkIfWordFound() {
        for word in wordsInPuzzle {
            let wordLetterCount = word.wordEntity.wordName!.count
            if wordLetterCount == currentSelection.count {
                var matches = 0
                for point in currentSelection {
                    if word.wordOccupiesPoint(point: point) {
                        matches += 1
                    } else {
                        break
                    }
                }
                if wordLetterCount == matches {
                    if !wordsFound.contains(word) {
                        selectedList.entity.wordsStudied += 1
                        selectedList.entity.updateDayWordsStudied()
                        wordsFound.append(word)
                        navigationItemOutlet.title = "\(wordsFound.count) / \(wordsInPuzzle.count)"
                        word.wordEntity.updateMastery(3)
                        word.wordEntity.wordFoundInPuzzle = wordSearchPuzzleEntity
                    }
                    self.collectionView.reloadData()

                    for selection in currentSelection {
                        labelArray[selection.y][selection.x].backgroundColor = .theme.blue //
                    }
                    if wordsFound.count == wordsInPuzzle.count { // puzzle finished
                        context.delete(wordSearchPuzzleEntity)
                        do {
                            try context.save()
                        } catch {
                            
                        }
        
                    
                        let dark = UIBlurEffect(style: UIBlurEffect.Style.dark)
                        let blurView: UIVisualEffectView = UIVisualEffectView(effect: dark)
                        view.addSubview(blurView)
                        blurView.alpha = 0.8
                        blurView.translatesAutoresizingMaskIntoConstraints = false
                        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                        blurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                        blurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                        
                        let popup = GameEndingPopup(title: "Nice Work!", message: "", imageName: "happyFlash")
                        popup.delegate = self
                        self.view.addSubview(popup)
                        
                        popup.clipsToBounds = true
                        popup.layer.cornerRadius = 7
                       
                        var width = view.frame.width - 50
                        var height = view.frame.height - 50
                        
                        if width > 250 {
                            width = 250
                        }
                        if height > 500 {
                            height = 500
                        }
                        
                        popup.frame = CGRect(x: view.frame.width / 2 - (width / 2), y: view.frame.height / 2 - (height / 2), width: width , height: height)
                        
                        let confettiController = confettiController(parentView: view)
                        view.layer.addSublayer(confettiController.confettiLayer)
                        
    
                    }
                    return
                }
            }

        }
        
        for selection in currentSelection {
            if selection.wordAtPoint(wordsInPuzzle: Array(wordsFound)) == nil {
                labelArray[selection.y][selection.x].backgroundColor = .white
                
            } else {
                labelArray[selection.y][selection.x].backgroundColor = .theme.blue
            }
        }
    }
    
    
    func approximateLineToAxis(orgin: CGPoint, endPoint: CGPoint) -> CGPoint {
        let zeroedEndPoint = CGPoint(x: endPoint.x - orgin.x, y: orgin.y - endPoint.y)
        let lineSlopes = [0.00001, 1.0, -1.0, 1000]
        
        var lowestDistance: Double?
        var linePoint: CGPoint?
        
        for lineSlope in lineSlopes {
            let slopeOfPerpendicularLine = -1 / (lineSlope)

            let b = zeroedEndPoint.y - (slopeOfPerpendicularLine * zeroedEndPoint.x)
            
            let stepOne = lineSlope - slopeOfPerpendicularLine
            let x = b / stepOne
            let y = slopeOfPerpendicularLine * x + b
            
            let distanceX: Double = abs(x - zeroedEndPoint.x)
            let distanceY: Double = abs(y - zeroedEndPoint.y)
            
            let c = pow((pow(distanceX, 2) + pow(distanceY, 2)), 0.5)
            
            if let distance = lowestDistance {
                if c < distance {
                    lowestDistance = c
                    linePoint = CGPoint(x: x, y: y)
                }
            } else {
                lowestDistance = c
                linePoint = CGPoint(x: x, y: y)
            }
            
        }
        
       
        
        return linePoint!
    }
    
    func selectLetterAlongLine(startPoint: CGPoint, endPointLocal: CGPoint) {
        let endPointGlobal = CGPoint(x: endPointLocal.x + startPoint.x , y: -endPointLocal.y + startPoint.y)
        let slope: Double = (endPointGlobal.y - startPoint.y) / (endPointGlobal.x - startPoint.x)
        let stepper: Double = Double((labelArray.first?.first?.frame.width)!) + 1
        let distance = pow((pow(abs(endPointGlobal.y - startPoint.y), 2) + pow(abs(endPointGlobal.x - startPoint.x),2)), 0.5) // a^2 + b^2 = c^2
        
        currentSelection.removeAll()
        for (y,labelRow) in labelArray.enumerated() {
            for (x,label) in labelRow.enumerated() {
                var found = false

                for i in 0...Int(ceil(distance / stepper)){
                    let checkLocation: Double = {
                        if endPointLocal.x > 0 {
                            return Double(i) * stepper
                        } else {
                            return Double(i) * stepper * -1
                            
                        }
                    }()

                    let k = checkLocation / (pow(1 + pow(slope, 2), 0.5))
                    
                    if touchInView(touchLocation: CGPoint(x: startPoint.x + k, y: startPoint.y + k * slope), view: label) {
    
                        label.backgroundColor = .theme.yellow
                        currentSelection.insert(PuzzlePoint(x: x, y: y))

                        found = true
                    }
                }
                if !found {
                    if PuzzlePoint(x: x, y: y).wordAtPoint(wordsInPuzzle: Array(wordsFound)) != nil {
                        labelArray[y][x].backgroundColor = .theme.blue //
                    } else {
                        labelArray[y][x].backgroundColor = .white
                    }
                }
            }
        }
    }
    
    
    func touchInView(touchLocation: CGPoint, view: UIView) -> Bool {
        let viewOrgin = view.globalFrame!.origin
        let viewSize = view.globalFrame!.size
        let viewMax = CGPoint(x: viewOrgin.x + viewSize.width - 2, y: viewOrgin.y + viewSize.height - 2)
        
        if touchLocation.x >= viewOrgin.x &&
            touchLocation.y >= viewOrgin.y &&
            touchLocation.x <= viewMax.x &&
            touchLocation.y <= viewMax.y {
            return true
        } else {
            return false
        }
    }
    
    
    
    func setUpStackView(screenSize: CGSize) {
        let availableWidth = screenSize.width - view.safeAreaInsets.right - view.safeAreaInsets.left
        let availableHeight = screenSize.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 35
        let limitingAxisSize = (availableWidth > availableHeight) ? availableHeight : availableWidth
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 1
        verticalStack.backgroundColor = .black
        verticalStack.isUserInteractionEnabled = true
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.heightAnchor.constraint(equalToConstant: limitingAxisSize).isActive = true
        verticalStack.widthAnchor.constraint(equalToConstant: limitingAxisSize).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.safeAreaInsets.left).isActive = true
        verticalStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top + 20).isActive = true
        
        
        if selectedList.entity.wordSearchPuzzle?.lettersInrow != 0  {
            gridSize = Int(selectedList.entity.wordSearchPuzzle!.lettersInrow)
        } else {
            // determine minimum grid size
            var minimumSize: Int = 1
            for word in selectedList.wordsArray {
                if word.wordName!.count > minimumSize {
                    minimumSize = word.wordName!.count
                }
            }
        
            let selectedSize: Int = gridSizes[difficultyMode.rawValue]!
            
            
            gridSize = (selectedSize >  minimumSize) ? selectedSize : minimumSize
            wordSearchPuzzleEntity.lettersInrow = Int16(gridSize)
        }

        for _ in 1...gridSize {
            let horizontalStack = UIStackView()
            horizontalStack.distribution = .fillEqually
            horizontalStack.axis = .horizontal
            horizontalStack.isUserInteractionEnabled = true
            horizontalStack.spacing = 1
            horizontalStack.backgroundColor = .black
            verticalStack.addArrangedSubview(horizontalStack)
            
            var labelTempArray: [UILabel] = []
            for _ in 1...gridSize {
                let letterLabel = UILabel()
                letterLabel.font = UIFont(name: "Times New Roman", size: 20)
                letterLabel.adjustsFontSizeToFitWidth = true
                letterLabel.numberOfLines = 0
                letterLabel.lineBreakMode = .byClipping
                letterLabel.minimumScaleFactor = 0.1
                letterLabel.backgroundColor = .white
                letterLabel.textColor = .black
                letterLabel.isUserInteractionEnabled = true
                letterLabel.textAlignment = .center
                letterLabel.layer.masksToBounds = false
                letterLabel.clipsToBounds = false
  
               
                labelTempArray.append(letterLabel)
                
                horizontalStack.addArrangedSubview(letterLabel)
                
            }
            labelArray.append(labelTempArray)
        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: self.view.safeAreaInsets.right).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.view.safeAreaInsets.bottom).isActive = true
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        
        collectionView.register(WordsFoundCollectionViewCell.self, forCellWithReuseIdentifier: WordsFoundCollectionViewCell.identifier)
        if (screenSize.width - view.safeAreaInsets.right - view.safeAreaInsets.left > screenSize.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) {
            collectionView.leftAnchor.constraint(equalTo: verticalStack.rightAnchor).isActive = true
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.safeAreaInsets.top).isActive = true
        } else {
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.view.safeAreaInsets.left).isActive = true
            collectionView.topAnchor.constraint(equalTo: verticalStack.bottomAnchor).isActive = true
        }
    }

    
    func layoutLettersFromString(letters: String) {
        var sortedLetters = Array(letters.reversed())
        for x in 0...gridSize - 1 {
            for y in 0...gridSize - 1 {
                labelArray[x][y].text = String(sortedLetters.popLast()!)
                
            }
        }
    }
    
    func layoutAsString() -> String {
        var letters: String = ""
        for labelArray in labelArray {
            for label in labelArray {
                letters += label.text!
            }
        }
        return letters
    }
    
    
    func layoutWords(allWords: [WordEntity]) {
        for word in allWords {
            var placeFound = false
            var allPoints: [PuzzlePoint] {
                var tempPoints: [PuzzlePoint] = []
                for x in 0...(gridSize - 1) {
                    for y in 0...(gridSize - 1) {
                        tempPoints.append(PuzzlePoint(x: x, y: y))
                    }
                }
                return tempPoints.shuffled()
            }
            for point in allPoints {
                if placeFound {
                    break
                }
                let directions: [WordDirection] = [.diagnanalDownLeft, .diagnanalDownRight, .diagnanalUpLeft, .diagnanalUpRight, .down, .left, .right, .up].shuffled()

                
                for direction in directions {
                    if let wordInPuzzle = createWord(orginPoint: point, direction: direction, word: word) {
                        placeFound = true
                        wordsInPuzzle.append(wordInPuzzle)
                        word.wordInPuzzle = wordSearchPuzzleEntity
                        break
                    }
                }
                
            }
            
        }
    }
    
    func createWord(orginPoint: PuzzlePoint, direction: WordDirection, word: WordEntity) -> WordInPuzzle? {
        var points: [PuzzlePoint] = []
        if (orginPoint.wordAtPoint(wordsInPuzzle: wordsInPuzzle) == nil) {
            points.append(orginPoint)
            for _ in 1...word.wordName!.count {
                let nextPoint = points.last!.getNextPoint(inDirection: direction)
                if nextPoint.isInGrid(gridSize: gridSize) && nextPoint.wordAtPoint(wordsInPuzzle: wordsInPuzzle) == nil {
                    points.append(nextPoint)
                } else {
                    break
                }
            }
        }

        if points.count == word.wordName!.count {
            for (i, point) in points.enumerated() {
                labelArray[point.y][point.x].text = String(word.wordName![i])
            }
            let wordPosition = WordPositionEntity(context: context)
            wordPosition.x = Int16(orginPoint.x)
            wordPosition.y = Int16(orginPoint.y)
            wordPosition.direction = Int16(direction.rawValue)
            
            word.wordPosition = wordPosition
            
            return WordInPuzzle(word: word)
        }
        return nil
    }
    
    
    func layoutRandomLetters(lettersToChooseFrom: [Character]) {
        for (y,row) in labelArray.enumerated() {
            for (x,label) in row.enumerated() {
                if PuzzlePoint(x: x, y: y).wordAtPoint(wordsInPuzzle: wordsInPuzzle) == nil {
                    label.text = lettersToChooseFrom.randomElement()?.description
                    
                }
            }
        }
    }
    

    
    // MARK: - PDF of word search
    func createPDF(letters: [[String]]) -> Data {
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
            headingTopPoint = addTitle(pageRect: pageRect, text: selectedList.name)
        
            headingTopPoint = addGrid(pageRect: pageRect, letters: letters, topTextPoint: headingTopPoint)
            addWordBank(pageRect: pageRect, words: wordsInPuzzle.map {$0.wordEntity.wordName!}, topTextPoint: headingTopPoint)
        }
        
        return data
            
    }
      
    func addTitle(pageRect: CGRect, text: String) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 35)!,
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
    
    
    func addGrid(pageRect: CGRect, letters: [[String]], topTextPoint: CGFloat) -> CGFloat {
        var yPoint: CGFloat = topTextPoint
        var xPoint: CGFloat = 25
        let letterSize: CGFloat = (pageRect.width - 50) /  CGFloat(letters.count)
        
        let letterAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 22)!,
            
        ]
        for row in letters {
            for letter in row {
                let attributedLetter = NSAttributedString(string: letter, attributes: letterAttributes)
                let letterRect = CGRect(x: xPoint, y: yPoint, width: letterSize, height: letterSize)
                
                attributedLetter.draw(in: letterRect)
                xPoint += letterSize
            }
            xPoint = 25
            yPoint += letterSize
        }
        return yPoint
    }
    
    func addWordBank(pageRect: CGRect, words: [String], topTextPoint: CGFloat) {
        var yPoint: CGFloat = topTextPoint
        var xPoint: CGFloat = 25
        let columnWidth: CGFloat = (pageRect.width - 50) / 6
        
        let wordAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 15)!,
        ]
        for word in words {
            let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)
            let letterRect = CGRect(x: xPoint, y: yPoint, width: columnWidth, height: attributedWord.size().height)
            
            attributedWord.draw(in: letterRect)
            xPoint += columnWidth
            if xPoint + columnWidth >= pageRect.width + 25 {
                xPoint = 25
                yPoint += attributedWord.size().height
            }
        }
    }
}





extension UIView {
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}
