//
//  RemindView.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit


class PrivateRemindView: UIView {
    
    static let ViewHeight = 120.0
    static let ViewWidth = 120.0
    static let LabelHeight = 30.0
    
    fileprivate var remindLabel: UILabel!
    
    fileprivate var _innerMsg: String?
    var curMsg: String? {
        set {
            _innerMsg = newValue
            
            guard let message = _innerMsg else {
                return
            }
            
            var textLength = (message as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30), options: [NSStringDrawingOptions.truncatesLastVisibleLine, NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil).size.width
            
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
        
        backgroundColor = UIColor.darkText
        alpha = 0.7
        layer.cornerRadius = 17
        
        remindLabel = UILabel(frame: CGRect(x: 15, y: 10, width: PrivateRemindView.ViewWidth, height: PrivateRemindView.LabelHeight))
        remindLabel.backgroundColor = UIColor.clear
        remindLabel.font = UIFont.systemFont(ofSize: 15)
        remindLabel.textColor = UIColor.white
        remindLabel.textAlignment = .center
        addSubview(remindLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RemindView: NSObject {
    
    static let shared = RemindView()
    
    //MARK: - fileprivate
    fileprivate var remindView: PrivateRemindView!
    fileprivate var timer: Timer?
    
    fileprivate override init() {
        remindView = PrivateRemindView(frame: CGRect.zero)
        remindView.isHidden = true
        let window = UIApplication.shared.windows[0]
        window.addSubview(remindView)
    }
    
    func showMessage(_ msg: String?) {
        guard let message = msg?.trimmingCharacters(in: .whitespacesAndNewlines), message.characters.count != 0  else {
            return
        }
        
        remindView.curMsg = message
        remindView.alpha = 0
        remindView.isHidden = false
        
        bringViewToFront()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.remindView.alpha = 0.7
        }) { (_) in
            self.performSelector(onMainThread: #selector(self.disappearNoticeView(notice:)), with: message, waitUntilDone: false)
        }
    }
    
    func bringViewToFront() {
        UIApplication.shared.windows[0].bringSubview(toFront: remindView)
    }
    
    func disappearNoticeView(notice: String?) {
        if let tm = timer {
            tm.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: Double(2), target: self, selector: #selector(hiddenNoticeView(timer:)), userInfo: notice, repeats: false)
    }
    
    func hiddenNoticeView(timer: Timer) {
        guard let notice = timer.userInfo as? String else {
            return
        }
        
        if remindView.curMsg == notice {
            self.remindView.alpha = 0
            self.remindView.isHidden = true
        }
    }
}
