//
//  String_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: -- alert message
typealias AlertMessage = String
extension AlertMessage {
    
    public struct UnKnown {
        public static let UnKnowError = "出错了"
    }
    
    //MARK: -- Client Error
    public struct Client {
        public static let ClientError = "请求出错了"
    }
    
    public struct Server {
        public static let ServerError = "服务暂不可用，请稍后重试"
    }
    
    //MARK: -- 网络相关
    public struct Internet {
        public static let NotConnectedToInternet = "亲，您的网络连接有问题哦~~"
        public static let NotConnectToHost = "对不起，无法连接到服务器"
        public static let TimedOutDesc = "请求超时，请重试"
    }
    
    //MARK: -- 登录相关
    public struct Login {
        public static let OutOfDate = "登录已过期，请重新登录"
        public static let NoUser = "您尚未登录，请登录"
    }
}


//MARK: - App版本 major.minor.patch
extension String {
    func version() -> (major: Int, minor: Int, patch: Int) {
        let array = components(separatedBy: ".")
        
        var ret: (major: Int, minor: Int, patch: Int) = (0, 0, 0)
        let count = array.count
        switch count {
        case 3:
            ret = (Int(array[0]) ?? 0, Int(array[1]) ?? 0, Int(array[2]) ?? 0)
        case 2:
            ret = (Int(array[0]) ?? 0, Int(array[1]) ?? 0, 0)
        case 1:
            ret = (Int(array[0]) ?? 0, 0, 0)
        default:
            ret = (0, 0, 0)
        }
        
        return ret
    }
}

import SwiftDate
//MARK: - 转化为Date
extension String {
    var date: Date? {
        do {
            let date = try DateInRegion(string: self, format: .custom("yyyy-MM-dd HH:mm:ss"))
            return date.absoluteDate
        } catch {
            return nil
        }
    }
}

