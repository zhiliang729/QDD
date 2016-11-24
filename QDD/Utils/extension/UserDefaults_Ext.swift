//
//  UserDefaults_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/24.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


extension UserDefaults {
    
    //清除registerDefaults中的某一个项目
    func unregisterDefault(forKey key: String) {
        var registeredDefaults = UserDefaults.standard.volatileDomain(forName: UserDefaults.registrationDomain)
        
        if (registeredDefaults[key] != nil) {
            registeredDefaults[key] = nil
            
            UserDefaults.standard.setVolatileDomain(registeredDefaults, forName: UserDefaults.registrationDomain)
        }
    }
    
    //修改webview的useragent
    func startSpoofing(userAgent: String) {
        UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
    }
    
    //清除webview的useragent
    func stopSpoofingUserAgent() {
        UserDefaults.standard.unregisterDefault(forKey: "UserAgent")
    }
}
