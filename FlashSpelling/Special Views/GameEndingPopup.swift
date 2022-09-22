//
//  VictoryViewPopup.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/26/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import UIKit

class GameEndingPopup: UIView {
    let title: String
    let message: String
    let imageName: String
    
    var delegate: gameEndingPopupDelegate!
    
    init(title: String, message: String, imageName: String) {
        self.title = title
        self.message = message
        self.imageName = imageName
        super.init(frame: .null)
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "spelling Background")
        self.addSubview(backgroundImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        let light = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: light)
        blurView.alpha = 0.85
        self.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Noteworthy", size: 30)
        titleLabel.layer.masksToBounds = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Bradley Hand", size: 17)
        messageLabel.layer.masksToBounds = true
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byClipping
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.textAlignment = .center
        self.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let exitButton = UIButton()
        exitButton.setTitle("Exit", for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "Noteworthy", size: 30)
     
        exitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        exitButton.titleLabel?.numberOfLines = 1
        
        exitButton.isUserInteractionEnabled = true
        exitButton.isSpringLoaded = true
        exitButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .highlighted)
        exitButton.titleLabel?.textAlignment = .center
        exitButton.addTarget(self, action: #selector(exitPressed), for: .touchUpInside)
        self.addSubview(exitButton)

        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        exitButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        exitButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        exitButton.systemLayoutSizeFitting(CGSize(width: 70, height: 50), withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultHigh)
        
        imageView.bottomAnchor.constraint(equalTo: exitButton.topAnchor).isActive = true
        
        
    }
    
    @objc func exitPressed() {
        delegate.exitPressed()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

protocol gameEndingPopupDelegate {
    func exitPressed()
}
