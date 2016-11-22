//
//  NSUserDefaults+Extension.swift
//  Daker
//
//  Created by RHCT on 16/8/25.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


extension NSUserDefaults {
    
    //清除registerDefaults中的某一个项目
    func unregisterDefaultForKey(defaultName: String) {
        var registeredDefaults = NSUserDefaults.standardUserDefaults().volatileDomainForName(NSRegistrationDomain)
        if (registeredDefaults[defaultName] != nil) {
            
            registeredDefaults[defaultName] = nil
            
            NSUserDefaults.standardUserDefaults().setVolatileDomain(registeredDefaults, forName: NSRegistrationDomain)
        }
    }
    
    //修改webview的useragent
    func startSpoofingUserAgent(userAgent: String) {
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": userAgent])
    }
    
    //清除webview的useragent
    func stopSpoofingUserAgent() {
        NSUserDefaults.standardUserDefaults().unregisterDefaultForKey("UserAgent")
    }
}

