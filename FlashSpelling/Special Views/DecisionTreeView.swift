//
//  decisionTreeView.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/29/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

import UIKit

class DecisionTreeView: UIView {
    var decisionTree: [treeItem]!
    var timer: Timer!
    var currentItemIndex: Int = 0

    var selectedPath: Int = 0
    var currentPageNew: (treeItem, Int)!
    var textView: UITextView!
    
    var tutorialResponseDelegate: tutorialResponseDelegate?
    
    var stackView: UIStackView!
    
    
    init(frame: CGRect, decisionTree: [treeItem]) {
        super.init(frame: frame)
        self.decisionTree = decisionTree
        self.backgroundColor = .none
        // position flash at bottom left corner
        
        let light = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: light)
        blurView.alpha = 0
        self.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        let image = UIImage(named: "happyFlash")!
        let flashImageView = UIImageView(image: image)
        flashImageView.contentMode = .scaleAspectFit
        self.addSubview(flashImageView)
        flashImageView.translatesAutoresizingMaskIntoConstraints = false
    
        let imageRatio = image.size.height / image.size.width
        let maxHeight = frame.height - 350
        var imageViewSize = CGSize(width: 275, height: 275 * imageRatio)
        if maxHeight < imageViewSize.height {
            imageViewSize.height = maxHeight
        }
        flashImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        flashImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        flashImageView.widthAnchor.constraint(equalToConstant: imageViewSize.width).isActive = true
        flashImageView.heightAnchor.constraint(equalToConstant: imageViewSize.height).isActive = true
        
        let bubbleImage: UIImage = UIImage(named: "bubble")!
        let bubbleOneImageView = UIImageView(image: bubbleImage)
        self.addSubview(bubbleOneImageView)
        bubbleOneImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleOneImageView.leftAnchor.constraint(equalTo: flashImageView.rightAnchor, constant: -20).isActive = true
        bubbleOneImageView.bottomAnchor.constraint(equalTo: flashImageView.topAnchor,constant: 50).isActive = true
        bubbleOneImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        bubbleOneImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bubbleOneImageView.alpha = 0
        
        let bubbleTwoImageView = UIImageView(image: bubbleImage)
        self.addSubview(bubbleTwoImageView)
        bubbleTwoImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleTwoImageView.leftAnchor.constraint(equalTo: flashImageView.rightAnchor, constant: -10).isActive = true
        bubbleTwoImageView.bottomAnchor.constraint(equalTo: flashImageView.topAnchor,constant: 10).isActive = true
        bubbleTwoImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bubbleTwoImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        bubbleTwoImageView.alpha = 0
        
        let textBubbleView = UIView()
        textBubbleView.backgroundColor = UIColor(red: 0.1, green: 200 / 255, blue: 1, alpha: 1)
        textBubbleView.layer.cornerRadius = 15
        textBubbleView.layer.borderWidth = 5
        textBubbleView.layer.borderColor = UIColor.black.cgColor
        self.addSubview(textBubbleView)
        textBubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        textBubbleView.rightAnchor.constraint(equalTo: bubbleTwoImageView.rightAnchor, constant: 0).isActive = true
        textBubbleView.bottomAnchor.constraint(equalTo: bubbleTwoImageView.topAnchor,constant: -10).isActive = true
        textBubbleView.widthAnchor.constraint(equalToConstant: 275).isActive = true
        textBubbleView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        textBubbleView.alpha = 0

        textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.font = UIFont(name: "Chalkboard SE Regular", size: 17)
        textView.backgroundColor = .clear
        textView.textColor = .black
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: textBubbleView.topAnchor, constant: 7).isActive = true
        textView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor, constant: 7).isActive = true
        textView.rightAnchor.constraint(equalTo: textBubbleView.rightAnchor, constant: -7).isActive = true
        
        
        
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.alpha = 0
        
        textBubbleView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5).isActive = true
        stackView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: textBubbleView.rightAnchor, constant: -10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor, constant: -10).isActive = true
        
        UIView.animate(withDuration: 0.5,delay: 1) {
            bubbleOneImageView.alpha = 1

        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                bubbleTwoImageView.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    textBubbleView.alpha = 1
                    blurView.alpha = 0.9
                } completion: { _ in
                    self.currentPageNew = (self.decisionTree.first!, 0)
                    self.setUpButtons()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.animateLetter), userInfo: nil, repeats: true)
                }

            }
        }


    }

    
    func setUpButtons() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for (i, option) in currentPageNew.0.options[selectedPath].enumerated() {
            let newButton = defaultButton()
            newButton.setTitle(option, for: .normal)
            newButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 17)
            newButton.titleLabel?.adjustsFontSizeToFitWidth = true
            newButton.titleLabel?.lineBreakMode = .byClipping
            newButton.titleLabel?.minimumScaleFactor = 0.1
            newButton.backgroundColor = .theme.grey
            newButton.titleLabel?.numberOfLines = 1
            newButton.setTitleColor(.theme.white, for: .normal)

            newButton.isSpringLoaded = true
            newButton.setTitleColor(.white, for: .highlighted)
            newButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            newButton.tag = i
            
            stackView.addArrangedSubview(newButton)
            
        }
    }
    
    func getNextTreeItem() -> treeItem? {
        let nextIndex = currentItemIndex + 1
        if decisionTree.count > nextIndex {
            return decisionTree[nextIndex]
        } else {
            return nil
        }
    }
    
    @objc func buttonPressed(sender: UIButton) {
        let selectedPath = sender.tag
        
        if let nextTreeItem = getNextTreeItem() {
            if !nextTreeItem.textPages[selectedPath].isEmpty {
                self.selectedPath = selectedPath
                currentItemIndex += 1
                currentPageNew = (nextTreeItem, 0)
                textView.text.removeAll()
                setUpButtons()
                stackView.alpha = 0
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.animateLetter), userInfo: nil, repeats: true)
                return
            }
        }
        
        UIView.animate(withDuration: 1) {
            self.center.x = -self.frame.size.width
            
        } completion: { [self] _ in
            removeFromSuperview()
            if tutorialResponseDelegate != nil {
                tutorialResponseDelegate?.selectedOption(optionIndex: selectedPath)
            }
        }
        
    }
    
    @objc func animateLetter() {
        let pageText = currentPageNew.0.textPages[selectedPath]
        let index = currentPageNew.1
        if index < pageText.count {
            let charToAdd = String(pageText[index])
            textView.text += charToAdd
            currentPageNew.1 += 1
            
            if [" ", ".", "'",",", "!", "?"].contains(charToAdd) {
                animateLetter()
            }
            
            
        } else {
            timer.invalidate()
            UIView.animate(withDuration: 0.25) {
                self.stackView.alpha = 1
            } completion: { _ in
                
            }

        }
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



protocol tutorialResponseDelegate {
    func selectedOption(optionIndex: Int)
}



struct treeItem {
    var textPages: [String]
    var options: [[String]] //button name
    
    init(textPages: [String], options: [[String]] = []) {
        self.textPages = textPages
        self.options = options
    }
    
}
