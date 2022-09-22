//
//  TutorialView.swift
//  FlashSpelling
//
//  Created by Hayden Kreuter on 8/23/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class TutorialView: UIView {
    var pages: [String]!
    var timer: Timer!
    var currentPageIndex: Int = 0
    var currentPage: (String, Int)!
    var textView: UITextView!
    var nextButton: UIButton!
    var delegate: tutorialDismisssedDelegate?
    
    
    init(frame: CGRect, pages: [String]) {
        super.init(frame: frame)
        self.pages = pages
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
        
        
        nextButton = defaultButton()
        nextButton.setTitle("Tap To Continue", for: .normal)
        
        
        textBubbleView.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: textBubbleView.centerXAnchor).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor, constant: -15).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        nextButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 25)
        nextButton.backgroundColor = .theme.grey
        nextButton.setTitleColor(.theme.white, for: .normal)

        nextButton.isSpringLoaded = true
        nextButton.setTitleColor(.white, for: .highlighted)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        nextButton.alpha = 0
        
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
                    self.currentPage = (pages.first!, 0)
                    self.timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.animateLetter), userInfo: nil, repeats: true)
                }

            }
        }


    }

    
    @objc func nextPressed() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            currentPage = (pages[currentPageIndex], 0)
            textView.text.removeAll()
            nextButton.alpha = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.animateLetter), userInfo: nil, repeats: true)
        } else {
            UIView.animate(withDuration: 1) {
                self.center.x = -self.frame.size.width
                
            } completion: { [self] _ in
                removeFromSuperview()
                if delegate != nil {
                    delegate?.tutorialDismissed()
                }
            }

            
        }
        
    }
    
    @objc func animateLetter() {
        let pageText = currentPage.0
        let index = currentPage.1
        if index < pageText.count {
            let charToAdd = String(pageText[index])
            textView.text += charToAdd
            currentPage.1 += 1
            
            if [" ", ".", "'",",", "!", "?"].contains(charToAdd) {
                animateLetter()
            }
            
            
        } else {
            timer.invalidate()
            UIView.animate(withDuration: 0.25) {
                self.nextButton.alpha = 1
            } completion: { _ in
                
            }

        }
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


protocol tutorialDismisssedDelegate {
    func tutorialDismissed()
    
}
