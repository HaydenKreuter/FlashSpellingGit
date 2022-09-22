//
//  CircularResultWheel.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 3/9/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation

import UIKit

class CircularResultWheelView: UIView {
    
    // MARK: - Properties -
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3/2 * Double.pi)
    private var scoreRatio: CGFloat!
    private var parentViewSize: CGSize!
    
    
    
    
    init(frame: CGRect, scoreRatio: CGFloat, parentViewSize: CGSize) {
        super.init(frame: frame)
        self.scoreRatio = scoreRatio
        self.parentViewSize = parentViewSize
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func createCircularPath() {
            // created circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: getRadius(), startAngle: startPoint, endAngle: endPoint, clockwise: true)
        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        // ui edits
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 15
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor(red: 60 / 255, green: 65 / 255, blue: 85 / 255, alpha: 1).cgColor
        // added circleLayer to layer
        layer.addSublayer(circleLayer)
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 7
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor(red: 96 / 255, green: 216 / 255, blue: 56 / 255, alpha: 1.0).cgColor
        // added progressLayer to layer
        layer.addSublayer(progressLayer)
        }
    
    func getRadius() -> CGFloat {
        if parentViewSize.height > parentViewSize.width {
            return parentViewSize.width / 2 - 10
        } else {
            return parentViewSize.height / 2 - 10
        }
    }
    
    func progressAnimation(duration: TimeInterval) {
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = scoreRatio
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        
    }
    
    
    
}
