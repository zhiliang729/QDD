//
//  G_Ext.swift
//  Daker
//
//  Created by RHCT on 16/8/1.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger

//MARK: - G 基本配置
extension G {
    func config() {
        G.initLogger()
        G.UserInfoConfig()
    }
}

//MARK: - 字符串常量
extension G {
    //MARK: -- api地址
    static let kDevAPIBaseURL = "http://api.lqxn1015.com"//开发段
    static let kProdAPIBaseURL = "http://api.hothuati.com"//测试段
    
    //MARK: -- sharesdk 相关信息
    static let ShareSDKID = "5219dc22a1a8"
    
    //MARK: --      weibo 相关信息
    static let WeiboAppKey = "3061025886"
    static let WeiboAppSecret = "1910a9c9344b01a1921dae67a29fa2a3"
    static let WeiboRedirectUri = "http://www.hothuati.com/"
    
    //MARK: --      wechat 相关信息
    static let WeChatAppID = "wx7594e1cd28decc01"
    static let WeChatAppSecret = "52ec314ea3b4b9c59f81aa8144130411"
    
    //MARK: --      qq 相关信息
    static let QQAppID = "1103967967"
    static let QQAppKey = "Mwm7ceIcIjdnl3SL"
    
    //MARK: -- JPUSH 相关信息
    static let JPUSHAppKey = "d78517b6110fee47d597e4ab"
    static let JPUSHChannel = "Apple Store"
    
    //MARK: -- Raven地址
    static let SentryUploadURL = "http://479aece65da2416c9d34aea31b43676a:a5bb927038b54646bea08be70260e04c@sentry.lqxn1015.com/4"
    
    //web 白名单
    static let whiteListedUrls = ["\\/\\/itunes\\.apple\\.com\\/"]
    
    //MARK:  -- notification name
    enum NotificationName: String {
        case userLoggedIn = "userLoginSuccess"//用户登录后通知
        case userLoggedOut = "userLogoutSuccess"//用户退出登录通知
        
        #if APPSTORE
        #else
        case platformChanged = "platformChanged"//平台切换通知
        #endif
        
        case alreadyShowHomePage = "alreadyShowHomePage"//已显示首页通知
    }
    
    //MARK: -- alert message
    enum AlertMessage: String {
        case unKnowErrorDesc = "出错了"
        
        //MARK: --     网络相关
        case notConnectedToInternetDesc = "亲，您的网络连接有问题哦~~"
        case cannotConnectToHostDesc = "对不起，无法连接到服务器"
        case timedOutDesc = "请求超时，请重试"
        
        //MARK: --     登录相关
        case loginOutOfDateDesc = "登录已过期，请重新登录"
        case noLoginUserDesc = "您尚未登录，请登录"
    }
    
    //MARK: -- NSUserDefaultKey name
    enum UserDefaultKey: String {
        case currentUserInfo = "CurrentUserInfoKey"//当前用户信息
        
        case appVersion = "AppVersionKey"//App 版本信息
        case appBuild = "AppBuildKey"//App build信息
        
        case appPlatform = "AppPlatformKey"//App 平台信息
        case appDevPlatform = "AppDevPlatform"//App dev platform
        case appProdPlatform = "AppProdPlatform"//App prod platform
        
        case alreadyShowStartHelp = "AlreadyShowStartHelp"//是否已显示启动帮助
        
        case closeAPNSNotification = "CloseAPNSNotification"//推送通知是否开启
    }
}

//MARK: - HTTP log 控制
extension G {
    static let ShowHTTPURL = false//是否显示http url
    static let ShowHTTPError = false //是否显示http error
    static let ShowHttpRespond = false//是否显示http response
    static let ShowUserAgent = false //是否显示http useragent
    static let ShowHostCookie = true //是否显示http cookies
}

//MARK: - 数字常量
extension G {
    //MARK: -- 屏幕宽度
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
    
    //MARK: -- 屏幕高度
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
}

//MARK: - 对象常量
extension G {
    
    //MARK: -- Main Storyboard
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    
    //MARK: -- AppDelegate
    static let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //MARK: -- Logger
    static let logger = XCGLogger.defaultInstance()
    
    //MARK: -- App version
    static let appVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    
    //MARK: -- App build
    static let appBuild = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
}

//MARK: - logger配置
extension G {
    class func initLogger() {
        G.logger.dateFormatter = NSDate.getDateFormat()
        var level = XCGLogger.LogLevel.Debug
        
        #if APPSTORE
            level = XCGLogger.LogLevel.None
        #else
        #endif
        G.logger.setup(level, showThreadName: false, showLogLevel: false, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: level)
    }
}

//MARK: - 用户相关
extension G {
    //用户是否已登录的简单判断
    class var userIsLogin: Bool {
        return G.instance.user != nil
    }
    
    //用户信息配置
    class func UserInfoConfig() {
        User.configCurrentUserInfo()
    }
}

//MARK: - Cookies 管理
extension G {
    class func clearSysCookies() {
        clearCookiesForHost(G.kDevAPIBaseURL)
        clearCookiesForHost(G.kProdAPIBaseURL)
    }
    
    class func clearCookiesForHost(host: String) {
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: host)!)
        if cookies?.count > 0 {
            for cookie in cookies! {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
    }
}

//MARK: - UserAgent组装
extension G {
    class func globalUserAgent() -> String {
        //2.0.0/iOS/7.0/iPhone/Jpush registrationID/渠道/uuid
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let sysType = "iOS"
        let sysVersion = UIDevice.currentDevice().systemVersion
        
        var sysInfo:[CChar] = Array(count:sizeof(utsname), repeatedValue: 0)
        let identifier = sysInfo.withUnsafeMutableBufferPointer { (inout ptr: UnsafeMutableBufferPointer<CChar>) -> String in
            uname(UnsafeMutablePointer<utsname>(ptr.baseAddress))
            let machinePtr = ptr.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))
            return String.fromCString(machinePtr)!
        }
        let jpushid = JPUSHService.registrationID() ?? ""
        let appstore = "app_store"
        let uuid = "abcdef12345676"
        let userAgentInfoArr = [appVersion, sysType, sysVersion, identifier, jpushid, appstore, uuid]
        let userAgent = userAgentInfoArr.joinWithSeparator("/")
        
        #if DEBUG
            if G.ShowUserAgent {
                G.logger.debug("\nUserAgent:\(userAgent)\n")
            }
        #else
        #endif
        
        return userAgent
    }
}

//MARK: - 提示消息简单调用
extension G {
    class func showMessage(msg: String?) {
        RemindView.instance.showMessage(msg)
    }
}

//MARK: - 平台相关
extension G {
    //当前平台base url
    static var platformBaseUrl: String {
        #if APPSTORE
            G.appdelegate.platformConfig(G.UserDefaultKey.appProdPlatform.rawValue)
            return G.kProdAPIBaseURL
        #else
            
            // 下面这样操作有效率问题，不过开发和测试还可以容忍吧
            var savedPlatform = NSUserDefaults.standardUserDefaults().objectForKey(G.UserDefaultKey.appPlatform.rawValue) as? String
            if savedPlatform == nil {
                savedPlatform = G.UserDefaultKey.appDevPlatform.rawValue
            }
            
            if savedPlatform == G.UserDefaultKey.appProdPlatform.rawValue {//pord
                return G.kProdAPIBaseURL
            } else {//dev
                return G.kDevAPIBaseURL
            }
        #endif
    }
}

//MARK: - 是否显示 启动帮助
extension G {
    static var showStartHelp: Bool {
        return true
    }
}

//MARK: - MainDelegate 直接调用
extension G {
    //MARK: -- 推出登录页
    class func pushLoginViewController() {
        G.appdelegate.mainDelegate.pushLoginViewController()
    }
    
    //MARK: -- 推出web页面
    class func handleUrl(url: NSURL?) {
        G.appdelegate.mainDelegate.handleUrl(url)
    }
    
    //MARK: -- 处理推送
    class func handleRemotePush() {
        G.appdelegate.mainDelegate.handleRemotePush()
    }
    
    //MARK: -- 若未登陆，执行登录，否则执行action
    class func loginOrPerformAction(action: () -> Void) {
        G.appdelegate.mainDelegate.loginOrPerformAction(action)
    }
    
    //MARK: -- 若未登陆，执行noLoginAction，否则执行alreadyLoginAction
    class func ifLogin(performAction alreadyLoginAction: (() -> Void)?, elsePerformAction noLoginAction: (() -> Void)? ) {
        G.appdelegate.mainDelegate.ifLogin(performAction: alreadyLoginAction, elsePerformAction: noLoginAction)
    }
    
    //MARK: -- 推出vc页面
    class func pushViewController(vc: UIViewController) {
        G.appdelegate.mainDelegate.pushViewController(vc)
    }
}

// MARK: - 一些常用方法
extension G {
    
     //MARK: -- 用户协议 可在web中直接loadHTMLString 的string
    class func userProtocolStr() -> String?  {
        let fpath = NSBundle.mainBundle().URLForResource("Protocol", withExtension: "html")
        
        do {
            let nightString = try String(contentsOfURL: fpath!, encoding: NSUTF8StringEncoding)
//            let nightTheme = "<body style=\"padding:20px; margin:0; background:rgb(21,21,21); color:#646464;font-size:14px;line-height:150%\">"
//            let dayTheme = "<body style=\"padding:20px; margin:0; background:#FFFFFF; color:#646464;font-size:14px;line-height:150%\">"
//            let dayString = nightString.stringByReplacingOccurrencesOfString(nightTheme, withString: dayTheme)
            return nightString
        } catch {
            return nil
        }
    }
}
