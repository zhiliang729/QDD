//
//  PlatformChangeView.swift
//  Daker
//
//  Created by RHCT on 16/8/3.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit

#if APPSTORE
#else
class PlatformChangeView: UIView, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    @IBOutlet var platButton: UIButton!
    @IBOutlet var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _ = NSBundle.mainBundle().loadNibNamed("PlatformChangeView", owner: self, options: nil)
        view.frame = UIScreen.mainScreen().bounds
        addSubview(view)
        
        alpha = 0
        hidden = true
        textView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configData() {
        textView.text = String(format: "UserAgent:\(G.globalUserAgent())\n测试web js: http://zhiliang729.github.io/testLogin.html\nUserInfo:\(G.instance.user?.dictionaryRepresentation().description)\n")
        
        if Daker.baseURL == G.kDevAPIBaseURL {
            platButton.setTitle("切换到prod平台", forState: .Normal)
        } else {
            platButton.setTitle("切换到dev平台", forState: .Normal)
        }
    }
    
    func disappear() {
        alpha = 0
        hidden = true
        textView!.resignFirstResponder()
    }
    
    @IBAction func hidenSelf(button: UIButton) {
        disappear()
    }
    
    @IBAction func toChangePlatform(button: UIButton) {
        if Daker.baseURL == G.kDevAPIBaseURL {//切换到prod平台
            G.appdelegate.platformConfig(G.UserDefaultKey.appProdPlatform.rawValue)
        } else {//切换到dev平台
            G.appdelegate.platformConfig(G.UserDefaultKey.appDevPlatform.rawValue)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(G.NotificationName.platformChanged.rawValue, object: nil)
        
        disappear()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "alpha" {
            if let newValue = change?[NSKeyValueChangeNewKey] as? NSNumber, newValue.floatValue - 0.8 < 0.00001 {
                UIApplication.sharedApplication().windows[0].bringSubviewToFront(self)
                configData()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        G.appdelegate.mainDelegate.handleUrl(URL)
        disappear()
        return false
    }
}

#endif
