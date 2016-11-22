//
//  TimerView.swift
//  Tomate
//
//  Created by dasdom on 29.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import QuartzCore

final class TimerView: UIView {
  
  var durationInSeconds: CGFloat = 0.0
  var maxValue: CGFloat = 60.0
  var showRemaining = true
  let timerShapeLayer: CAShapeLayer
  let secondsShapeLayer: CAShapeLayer
  let timeLabel: UILabel
    
    private var radius: CGFloat = 0.0
    private var timerCenter: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private let startAngle = -CGFloat(M_PI) / 2
    private let endAngle = 3 * CGFloat(M_PI) / 2
    
    private var timerRingPath: UIBezierPath!
    private var secondsRingPath: UIBezierPath!
    private var fullRingPath: UIBezierPath!
  
  override init(frame: CGRect) {
    
    timerShapeLayer = CAShapeLayer()
    //        fullShapeLayer = CAShapeLayer()
    secondsShapeLayer = CAShapeLayer()
    
    timeLabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      //            label.font = UIFont.systemFontOfSize(80)
      //            label.font = UIFont(name: "HiraKakuProN-W3", size: 80)
      label.font = UIFont(name: "HelveticaNeue-Thin", size: 80)
//      label.adjustsFontSizeToFitWidth = true
      label.textAlignment = .Center
      label.textColor = TimerStyleKit.timerColor
//      label.backgroundColor = UIColor.yellowColor()
      return label
      }()
    
    super.init(frame: frame)
    backgroundColor = UIColor.clearColor()
    
    addSubview(timeLabel)
    
    layer.addSublayer(timerShapeLayer)
    //        layer.addSublayer(fullShapeLayer)
    layer.addSublayer(secondsShapeLayer)
    
    
    if #available(iOS 9.0, *) {
        var constraints = [NSLayoutConstraint]()
        constraints.append(timeLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor))
        constraints.append(timeLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor))
        NSLayoutConstraint.activateConstraints(constraints)
    } else {
        // Fallback on earlier versions
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect)
  {
    //        TimerStyleKit.drawTimer(durationInSeconds, maxValue: maxValue, showRemaining: showRemaining)
    
//    var percentage: CGFloat
//    var dummyInt: Int
//    if !showRemaining {
//      dummyInt = Int(100000.0*(1 - (durationInSeconds-1) / maxValue))
//      //            percentage = 1 - durationInSeconds / maxValue
//    } else {
//      dummyInt = Int(100000.0*(durationInSeconds-1) / maxValue)
//      //            percentage = durationInSeconds / maxValue
//    }
//    percentage = CGFloat(dummyInt)/100000.0
    
//    let timerCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
//    let radius = rect.size.width / 2 - 10
    timerCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
    radius = rect.size.width / 2 - 10
    
    initTimerState()
    settingTimerRingStyle()
    settingSecondsRingStyle()
    settingFullRingStyle()
    G.logger.debug("Draw Rect")
    
//    let startAngle = 3 * CGFloat(M_PI)/2
    
//    let timerRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius, startAngle: startAngle, endAngle: startAngle-0.001, clockwise: true)

    //        timerRingPath.addArcWithCenter(timerCenter, radius: radius, startAngle: startAngle, endAngle: startAngle - 0.001, clockwise: true)
    
    //        println("percentage: \(percentage)")
//    timerShapeLayer.fillColor = UIColor.clearColor().CGColor
//    timerShapeLayer.strokeColor = TimerStyleKit.timerColor.CGColor
//    timerShapeLayer.lineWidth = 3
//    timerShapeLayer.strokeEnd = percentage
//    timerShapeLayer.path = timerRingPath.CGPath
    //        timerShapeLayer.shadowColor = TimerStyleKit.timerColor.CGColor
    //        timerShapeLayer.shadowOffset = CGSizeMake(0.1, -0.1)
    //        timerShapeLayer.shadowRadius = 3
    //        timerShapeLayer.shadowOpacity = 1.0
    
//    let totalMinutes = (maxValue-1) / 60
//    let dashLength = 2*radius*CGFloat(M_PI)/totalMinutes;
//    timerShapeLayer.lineDashPattern = [dashLength-2, 2]
    
//    var secondsPercentage: CGFloat
//    if showRemaining {
//      secondsPercentage = (durationInSeconds-1) % 60.0
//    } else {
//      secondsPercentage = 60.0 - (durationInSeconds-1) % 60.0
//      
//    }
//    let secondsRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius-4, startAngle: startAngle, endAngle: startAngle-0.001, clockwise: true)

    
//    secondsShapeLayer.fillColor = UIColor.clearColor().CGColor
//    secondsShapeLayer.strokeColor = TimerStyleKit.timerColor.CGColor
//    secondsShapeLayer.lineWidth = 1.0
//    secondsShapeLayer.strokeEnd = CGFloat(secondsPercentage)/60.0
//    secondsShapeLayer.path = secondsRingPath.CGPath
    //        secondsShapeLayer.shadowColor = TimerStyleKit.timerColor.CGColor
    //        secondsShapeLayer.shadowOffset = CGSizeMake(0.1, -0.1)
    //        secondsShapeLayer.shadowRadius = 3
    //        secondsShapeLayer.shadowOpacity = 1.0
    
    //        println("timerShapeLayer \(timerShapeLayer)")
    
//    TimerStyleKit.timerColor.set()
    
//    let fullRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius+4, startAngle: startAngle, endAngle: startAngle - 0.001, clockwise: true)

//    fullRingPath.lineWidth = 1.0
//    fullRingPath.stroke()
    
    //        fullShapeLayer.fillColor = UIColor.clearColor().CGColor
    //        fullShapeLayer.strokeColor = TimerStyleKit.timerColor.CGColor
    //        fullShapeLayer.lineWidth = 1
    //        fullShapeLayer.strokeEnd = 1.0
    //        fullShapeLayer.path = fullRingPath.CGPath
    
    //        let path = UIBezierPath(arcCenter: timerCenter, radius: radius-4, startAngle: startAngle, endAngle: startAngle - 0.001, clockwise: true)
    //        path.lineWidth = 0.5
    //        path.stroke()
    
//    if !showRemaining {
//      durationInSeconds = maxValue - durationInSeconds
//    }
//    let seconds = Int(durationInSeconds % 60)
//    let minutes = Int(durationInSeconds / 60.0)
//    let format = "02"
//    let labelText = "\(minutes.format(format))" + ":" + "\(seconds.format(format))"
//    
//    timeLabel.text = labelText
//    timeLabel.setNeedsLayout()
  }
    
    func updateTimer() {
        var percentage: CGFloat
        var dummyInt: Int
        if !showRemaining {
            dummyInt = Int(100000.0*(1 - (durationInSeconds-1) / maxValue))
            //            percentage = 1 - durationInSeconds / maxValue
        } else {
            dummyInt = Int(100000.0*(durationInSeconds-1) / maxValue)
            //            percentage = durationInSeconds / maxValue
        }
        percentage = CGFloat(dummyInt)/100000.0
        
        var secondsPercentage: CGFloat
        if showRemaining {
            secondsPercentage = (durationInSeconds-1) % 60.0
        } else {
            secondsPercentage = 60.0 - (durationInSeconds-1) % 60.0
            
        }
        
        if !showRemaining {
            durationInSeconds = maxValue - durationInSeconds
        }
        let seconds = Int(durationInSeconds % 60)
        let minutes = Int(durationInSeconds / 60.0)
        
        let labelText = "\(String(format: "%02d", minutes))" + ":" + "\(String(format: "%02d", seconds))"
        
        timeLabel.text = labelText
        
        let totalMinutes = (maxValue-1) / 60
        let dashLength = 2*radius*CGFloat(M_PI)/totalMinutes;
        timerShapeLayer.lineDashPattern = [dashLength-2, 2]
        
        timerShapeLayer.strokeEnd = percentage
        secondsShapeLayer.strokeEnd = CGFloat(secondsPercentage) / 60.0
    }
    
    private func initTimerState() {
        timerShapeLayer.strokeEnd = 0.0
        secondsShapeLayer.strokeEnd = 0.0
    }
    
    private func settingTimerRingStyle() {
        timerRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        timerShapeLayer.path = timerRingPath.CGPath
        
        timerShapeLayer.fillColor = UIColor.clearColor().CGColor
        timerShapeLayer.strokeColor = TimerStyleKit.timerColor.CGColor
        timerShapeLayer.lineWidth = 3
    }
    
    private func settingSecondsRingStyle() {
        secondsRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius-4, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        secondsShapeLayer.path = secondsRingPath.CGPath
        
        secondsShapeLayer.fillColor = UIColor.clearColor().CGColor
        secondsShapeLayer.strokeColor = TimerStyleKit.timerColor.CGColor
        secondsShapeLayer.lineWidth = 1.0
        //secondsShapeLayer.strokeEnd = CGFloat(secondsPercentage)/60.0
    }
    
    private func settingFullRingStyle() {
        TimerStyleKit.timerColor.set()
        
        fullRingPath = UIBezierPath(arcCenter: timerCenter, radius: radius+4, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        fullRingPath.lineWidth = 1.0
        fullRingPath.stroke()
    }
    
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    showRemaining = !showRemaining
//    setNeedsDisplay()
    updateTimer()
  }
  
}
