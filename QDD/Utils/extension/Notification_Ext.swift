//
//  Notification_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct User {
        public static let DidLogin = Notification.Name(rawValue: "rhct.notification.name.user.LoginSuccess")
        
        public static let DidLogout = Notification.Name(rawValue: "rhct.notification.name.user.LogoutSuccess")
    }
    
    public struct App {
        public static let PlatformChanged = Notification.Name(rawValue: "rhct.notification.name.app.platformChanged")
        
        public static let AlreadyShowHomePage = Notification.Name(rawValue: "rhct.notification.name.app.alreadyShowHomePage")
    }
}
