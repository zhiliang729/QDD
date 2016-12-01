//
//  G_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import Kingfisher

//MARK: - G 基本配置
extension G {
    func config() {
        G.initLogger()
        
        //图片缓存大小，默认无限制
//        ImageCache.default.maxDiskCacheSize = 50 * 1024 * 1024
        //图片过期时间，默认为一周
//        ImageCache.default.maxCachePeriodInSecond = 7 * 24 * 60 * 60
        //设置扩展名
//        KingfisherManager.shared.cache.pathExtension = "jpg"
        //设置下载超时时间，默认15秒
//        ImageDownloader.default.downloadTimeout = 30.0
        
        G.UserInfoConfig()
    }
}

//MARK: - 字符串常量
extension G {
    //MARK: -- api地址
    static let DevAPIBaseURL = "http://api.lqxn1015.com"//开发段
    static let ProdAPIBaseURL = "https://api.hothuati.com"//测试段
    
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
    static let JPUSHAppKey = "40e8aa5ce00b7c802e5c743e"
    static let JPUSHChannel = "Apple Store"
    
    //MARK: -- Raven地址
    static let SentryUploadURL = "http://479aece65da2416c9d34aea31b43676a:a5bb927038b54646bea08be70260e04c@sentry.lqxn1015.com/4"
    
    //web 白名单
    static let whiteListedUrls = ["\\/\\/itunes\\.apple\\.com\\/"]
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
    static let SCREEN_WIDTH = UIScreen.main.bounds.width
    
    //MARK: -- 屏幕高度
    static let SCREEN_HEIGHT = UIScreen.main.bounds.height
}

//MARK: - 对象常量
extension G {
    
    //MARK: -- Main Storyboard
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    //MARK: -- AppDelegate
    static let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: -- Logger
    static let logger = XCGLogger.default
    
    //MARK: -- App version
    static let appVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    //MARK: -- App build
    static let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
}

//MARK: - logger配置
extension G {
    class func initLogger() {
        var level = XCGLogger.Level.debug
        
        #if APPSTORE
            level = XCGLogger.Level.none
        #else
        #endif
        G.logger.setup(level: level, showThreadName: false, showLevel: false, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: level)
    }
}

//MARK: - 用户相关
extension G {
    //用户是否已登录的简单判断
    class var userIsLogin: Bool {
        return G.shared.user != nil
    }
    
    //用户信息配置
    class func UserInfoConfig() {
        User.configCurrentUserInfo()
    }
}

//MARK: - Cookies 管理
extension G {
    class func clearSysCookies() {
        clearCookies(host: G.DevAPIBaseURL)
        clearCookies(host: G.ProdAPIBaseURL)
    }
    
    class func clearCookies(host: String) {
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: host)!), cookies.count > 0 {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}

//MARK: - UserAgent组装
extension G {
    class func globalUserAgent() -> String {
        //2.0.0/iOS/7.0/iPhone/Jpush registrationID/渠道/uuid
        let appVersion = G.appVersion
        let sysType = "iOS"
        let sysVersion = UIDevice.current.systemVersion
        
        let identifier: String = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let mirror = Mirror(reflecting: systemInfo.machine)
            
            let identifier = mirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }()
        
        let jpushid = JPUSHService.registrationID() ?? ""
        let appstore = "app_store"
        let uuid = "abcdef12345676"
        let userAgentInfoArr = [appVersion, sysType, sysVersion, identifier, jpushid, appstore, uuid]
        let userAgent = userAgentInfoArr.joined(separator: "/")
        
        #if DEBUG
            if G.ShowUserAgent {
                G.logger.debug("\nUserAgent:\(userAgent)\n")
            }
        #else
        #endif
        
        return userAgent
    }
}

//MARK: - http header
import Alamofire
extension G {
    class func httpHeaders() -> HTTPHeaders? {
        let headers = [
            "Accept-Language": "en;q=0.8,zh-Hans;q=0.5,zh-Hant;",
            "Accept-Encoding": "gzip;q=0.8,compress;",
            "User-Agent":G.globalUserAgent()
        ]
        return headers
    }
}

//MARK: - 提示消息简单调用
extension G {
    class func showMessage(_ msg: String?) {
        RemindView.shared.showMessage(msg)
    }
}

//MARK: - 平台相关
extension G {
    //当前平台base url
    static var platformBaseUrl: String {
        #if APPSTORE
            G.appdelegate.platformConfig(platform: UserDefaults.Key.AppProdPlatform)
            return G.ProdAPIBaseURL
        #else
            
            // 下面这样操作有效率问题，不过开发和测试还可以容忍吧
            var savedPlatform = UserDefaults.standard.object(forKey: UserDefaults.Key.AppPlatform) as? String
            if savedPlatform == nil {
                savedPlatform = UserDefaults.Key.AppDevPlatform
            }
            
            if savedPlatform == UserDefaults.Key.AppProdPlatform {//pord
                return G.ProdAPIBaseURL
            } else {//dev
                return G.DevAPIBaseURL
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
    class func handleUrl(_ url: URL?) {
        G.appdelegate.mainDelegate.handleUrl(url)
    }
    
    //MARK: -- 处理推送
    class func handleRemotePush() {
        G.appdelegate.mainDelegate.handleRemotePush()
    }
    
    //MARK: -- 若未登陆，执行登录，否则执行action
    class func loginOrPerformAction(_ action: @escaping () -> Void) {
        G.appdelegate.mainDelegate.loginOrPerformAction(action)
    }
    
    //MARK: -- 若未登陆，执行noLoginAction，否则执行alreadyLoginAction
    class func ifLogin(performAction alreadyLoginAction: (() -> Void)?, elsePerformAction noLoginAction: (() -> Void)? ) {
        G.appdelegate.mainDelegate.ifLogin(performAction: alreadyLoginAction, elsePerformAction: noLoginAction)
    }
    
    //MARK: -- 推出vc页面
    class func push(_ vc: UIViewController) {
        G.appdelegate.mainDelegate.push(vc)
    }
}

// MARK: - 一些常用方法
extension G {
    
    //MARK: -- 用户协议 可在web中直接loadHTMLString 的string
    class func userProtocolStr() -> String?  {
        guard let fpath = Bundle.main.url(forResource: "Protocol", withExtension: "html") else {
            return nil
        }
        
        do {
            let nightString = try String(contentsOf: fpath, encoding: String.Encoding.utf8)
//            let nightTheme = "<body style=\"padding:20px; margin:0; background:rgb(21,21,21); color:#646464;font-size:14px;line-height:150%\">"
//            let dayTheme = "<body style=\"padding:20px; margin:0; background:#FFFFFF; color:#646464;font-size:14px;line-height:150%\">"
//            let dayString = nightString.replacingOccurrences(of: nightTheme, with: dayTheme)
            return nightString
        } catch {
            return nil
        }
    }
}


