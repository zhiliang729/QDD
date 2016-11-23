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
        public static let didLogin = Notification.Name(rawValue: "rhct.notification.name.user.LoginSuccess")
        
        public static let didLogout = Notification.Name(rawValue: "rhct.notification.name.user.LogoutSuccess")
        
        public static let platformChanged = Notification.Name(rawValue: "rhct.notification.name.user.platformChanged")
        
        public static let alreadyShowHomePage = Notification.Name(rawValue: "rhct.notification.name.user.alreadyShowHomePage")
    }
}
