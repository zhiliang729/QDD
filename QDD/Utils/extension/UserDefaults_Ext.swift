//
//  UserDefaults_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/24.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: -  key
extension UserDefaults {
    
    public struct Key {
        /// User info dictionary key representing the `URLSessionTask` associated with the notification.
        public static let CurUserInfo = "rhct.userdefaults.key.curuserinfo"
        
        
        public static let AppVersion = "rhct.userdefaults.key.appversion"//App 版本信息
        
        public static let AppPlatform = "rhct.userdefaults.key.appplatform"//App 平台信息
        public static let AppDevPlatform = "rhct.userdefaults.key.appdevplatform"//App dev platform
        public static let AppProdPlatform = "rhct.userdefaults.key.appprodplatform"//App prod platform
        
        public static let AlreadyShowStartHelp = "rhct.userdefaults.key.alreadyshowstarthelp"//是否已显示启动帮助
        
        public static let CloseAPNSNotification = "rhct.userdefaults.key.closeapnsnotification"//推送通知是否开启
    }
}

//MARK: - ios8以下 UserAgent
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

