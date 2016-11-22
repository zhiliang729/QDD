//
//  RemindView.swift
//  Daker
//
//  Created by RHCT on 16/8/1.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import SwiftString


class PrivateRemindView: UIView {
    static let ViewHeight = 120.0
    static let ViewWidth = 120.0
    static let LabelHeight = 30.0
    
    private var remindLabel: UILabel!
    
    private var _innerMsg: String?
    var curMsg: String? {
        set {
            _innerMsg = newValue
            
            guard let message = _innerMsg else {
                return
            }
            
            var textLength = (message as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: 30), options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)], context: nil).size.width
            
            textLength = textLength + 30
            
            if textLength > G.SCREEN_WIDTH {
                textLength = G.SCREEN_WIDTH - 10
            }
            
            if textLength < 80 {
                textLength = 80
            }
            
            var screen4InchLowerGap: CGFloat = 0.0
            if G.SCREEN_WIDTH < 569 {
                screen4InchLowerGap = 50
            }
            
            remindLabel.frame = CGRect(x: 15.0, y: 10.0, width: CGFloat(textLength - 30), height: CGFloat(PrivateRemindView.LabelHeight))
            remindLabel.text = message
            frame = CGRect(x: (G.SCREEN_WIDTH - textLength) / 2.0, y: (G.SCREEN_HEIGHT - CGFloat(PrivateRemindView.LabelHeight + 20) - screen4InchLowerGap) / 2.0, width: textLength, height: CGFloat(PrivateRemindView.LabelHeight + 20))
        }
        
        get {
            return _innerMsg
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.darkTextColor()
        alpha = 0.7
        layer.cornerRadius = 17
        
        remindLabel = UILabel(frame: CGRect(x: 15, y: 10, width: PrivateRemindView.ViewWidth, height: PrivateRemindView.LabelHeight))
        remindLabel.backgroundColor = UIColor.clearColor()
        remindLabel.font = UIFont.systemFontOfSize(15)
        remindLabel.textColor = UIColor.whiteColor()
        remindLabel.textAlignment = .Center
        addSubview(remindLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RemindView: NSObject {
    
    static let instance = RemindView()
    
    //MARK: - private
    private var remindView: PrivateRemindView!
    private var timer: NSTimer?
    
    private override init() {
        remindView = PrivateRemindView(frame: CGRect.zero)
        remindView.hidden = true
        let window = UIApplication.sharedApplication().windows[0]
        window.addSubview(remindView)
    }
    
    func showMessage(msg: String?) {
        guard let message = msg?.trimmed() where message.characters.count != 0  else {
            return
        }
        
        remindView.curMsg = message
        remindView.alpha = 0
        remindView.hidden = false
        
        bringViewToFront()
        
        UIView.animateWithDuration(0.3, animations: { 
            self.remindView.alpha = 0.7
            }) { (_) in
                self.performSelectorOnMainThread(#selector(self.disappearNoticeView(_:)), withObject: message, waitUntilDone: false)
        }
    }
    
    func bringViewToFront() {
        UIApplication.sharedApplication().windows[0].bringSubviewToFront(remindView)
    }
    
    func disappearNoticeView(notice: String?) {
        if let tm = timer {
            tm.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(2), target: self, selector: #selector(hiddenNoticeView(_:)), userInfo: notice, repeats: false)
    }
    
    func hiddenNoticeView(timer: NSTimer) {
        guard let notice = timer.userInfo as? String else {
            return
        }
        
        if remindView.curMsg == notice {
            self.remindView.alpha = 0
            self.remindView.hidden = true
        }
    }
}
