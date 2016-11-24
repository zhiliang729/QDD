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
        
        _ = Bundle.main.loadNibNamed("PlatformChangeView", owner: self, options: nil)
        view.frame = UIScreen.main.bounds
        addSubview(view)
        
        alpha = 0
        isHidden = true
        textView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configData() {
        textView.text = String(format: "UserAgent:\(G.globalUserAgent())\n测试web js: http://zhiliang729.github.io/testLogin.html\nUserInfo:\(G.shared.user?.dictionaryRepresentation().description)\n")
        
        if G.platformBaseUrl == G.DevAPIBaseURL {
            platButton.setTitle("切换到prod平台", for: .normal)
        } else {
            platButton.setTitle("切换到dev平台", for: .normal)
        }
    }
    
    func disappear() {
        alpha = 0
        isHidden = true
        textView!.resignFirstResponder()
    }
    
    @IBAction func hidenSelf(button: UIButton) {
        disappear()
    }
    
    @IBAction func toChangePlatform(button: UIButton) {
        if G.platformBaseUrl == G.DevAPIBaseURL {//切换到prod平台
            G.appdelegate.platformConfig(platform: G.UserDefaultKey.appProdPlatform.rawValue)
        } else {//切换到dev平台
            G.appdelegate.platformConfig(platform: G.UserDefaultKey.appDevPlatform.rawValue)
        }
        
        NotificationCenter.default.post(name: Notification.Name.App.PlatformChanged, object: nil)
        disappear()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "alpha" {
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber, newValue.floatValue - 0.8 < 0.00001 {
                UIApplication.shared.windows[0].bringSubview(toFront: self)
                configData()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        G.appdelegate.mainDelegate.handleUrl(URL as NSURL?)
        disappear()
        return false
    }
}

#endif
