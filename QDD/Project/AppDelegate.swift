//
//  AppDelegate.swift
//  Daker
//
//  Created by RHCT on 16/7/27.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mainTabBar: UITabBarController!
    
    var mainDelegate: MainDelegateController = MainDelegateController()
    
    private var hostReach: Reachability?
    
    #if APPSTORE
    #else
    private var platformView: PlatformChangeView? //平台切换view  只在 非APPSTORE下 有效
    #endif
    
    deinit {
        #if APPSTORE
        #else
            platformView!.removeObserver(self.platformView!, forKeyPath: "alpha")
        #endif
        
        
        //JPUSH
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJPFNetworkDidSetupNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJPFNetworkDidCloseNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJPFNetworkDidRegisterNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kJPFNetworkDidLoginNotification, object: nil)
        
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: - 首先配置
        //MARK: -- 全局数据配置
        G.instance.config()
        
        //MARK: -- 平台配置
        platformConfig("")
        
        //MARK: -- timer
        registerDefaultUserDefaults()
        
        //MARK: -- 不同版本之间数据清理及升级
        appVersionConfig()
        
        //MARK: -- 启动帮助页是否已显示
        G.instance.finishedStartHelp = false
        //MARK: - 其次配置
        
        //MARK: -- NSURL cache
        urlCacheConfig()
        
        //MARK: -- Raven日志系统
        ravenConfig()
        
        //MARK: -- sharesdk
        sharesdkConfig()
        
        //MARK: -- jpush
        jpushConfig(launchOptions)
        
        //MARK: -- 友盟
        umengConfig()
        
        //MARK: -- 网络监测
        checkNetworkChange()
        
        //MARK: -- 设置window相关
        configWindow()
        
        //MARK: -- tabbar
        configTabbar()
        
        
        //MARK: -- 启动帮助页
        startHelp()
        
        //MARK: -- 手势捏合切换平台 （非APPSTORE 有效）
        #if APPSTORE
        #else
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(platformChange(_:)), name: G.NotificationName.platformChanged.rawValue, object: nil)
            addTwoFingerPinchGesture()
        #endif
        
        return true
    }
    
    private func appVersionConfig() {
        let versionStr = G.appVersion
        let version = versionStr.version()
        
        let savedVersionStr = NSUserDefaults.standardUserDefaults().objectForKey(G.UserDefaultKey.appVersion.rawValue) as? String
        
        if versionStr != savedVersionStr {//升级版本首次启动时，进行相应的数据处理
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: G.UserDefaultKey.closeAPNSNotification.rawValue)//默认打开推送
            
            let savedVersion = savedVersionStr?.version()
            if savedVersionStr == nil {//首次安装
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: G.UserDefaultKey.alreadyShowStartHelp.rawValue)
            } else if version.major != savedVersion?.major ?? 0 {//大版本升级
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: G.UserDefaultKey.alreadyShowStartHelp.rawValue)
            } else {//小版本升级
                if G.showStartHelp {//产品控制
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: G.UserDefaultKey.alreadyShowStartHelp.rawValue)
                } else {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: G.UserDefaultKey.alreadyShowStartHelp.rawValue)
                }
            }
            
            //保存版本信息
            NSUserDefaults.standardUserDefaults().setObject(versionStr, forKey: G.UserDefaultKey.appVersion.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    //MARK: - window设置
    private func configWindow() {
        window?.backgroundColor = UIColor.whiteColor()
    }
    
    //MARK: - tabbar设置
    private func configTabbar() {
        mainTabBar = window!.rootViewController as! UITabBarController
        mainTabBar.delegate = mainDelegate
        
        let firstNavi = mainTabBar.viewControllers![0] as! UINavigationController
        firstNavi.delegate = mainDelegate
        
        let secondNavi = mainTabBar.viewControllers![1] as! UINavigationController
        secondNavi.delegate = mainDelegate
        
        let thirdNavi = mainTabBar.viewControllers![2] as! UINavigationController
        thirdNavi.delegate = mainDelegate
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        JPUSHService.resetBadge()
        JPUSHService.setBadge(0)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

//MARK: - 检测网络变化
extension AppDelegate {
    func checkNetworkChange() {
        if (hostReach != nil) {
            hostReach?.stopNotifier()
            hostReach = nil
        }
        
        let hostUrlName = G.platformBaseUrl.substringFromIndex("http://".startIndex.advancedBy("http://".characters.count))
        do {
            hostReach = try Reachability(hostname: hostUrlName)
            try hostReach?.startNotifier()
        } catch {
            G.logger.debug("\n*********** 网络监测未初始化成功 \n**********\n")
            return
        }
    }
}

//MARK: - 平台配置
extension AppDelegate {
    
    func platformConfig(platform: String) {
        var plat = platform
        let savedPlatform = NSUserDefaults.standardUserDefaults().objectForKey(G.UserDefaultKey.appPlatform.rawValue) as? String
        
        if plat.characters.count == 0 {
            #if APPSTORE
                let value = G.UserDefaultKey.appProdPlatform.rawValue
            #else
                let value = G.UserDefaultKey.appDevPlatform.rawValue
            #endif
            
            plat = savedPlatform ?? value
        }
        
        if savedPlatform == nil {//首次打开app
            //do nothing
        } else if plat == savedPlatform {//同一平台
            //do nothing
        } else {//不同平台，执行切换相关操作
            
            //执行退出登录的操作，清除用户信息
            G.instance.user = nil
            User.cancelAuthorize()
        }
        
        NSUserDefaults.standardUserDefaults().setObject(plat, forKey: G.UserDefaultKey.appPlatform.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    #if APPSTORE
    #else
    func platformChange(noti: NSNotification) {
        checkNetworkChange()
    }
    
    private func addTwoFingerPinchGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(getTwoFingerPinchGesture(_:)))
        window?.addGestureRecognizer(gesture)
        
        platformView = PlatformChangeView(frame: UIScreen.mainScreen().bounds)
        platformView!.addObserver(platformView!, forKeyPath: "alpha", options: .New, context: nil)
        let awin = UIApplication.sharedApplication().windows[0]
        platformView!.hidden = true
        awin.addSubview(platformView!)
    }
    
    func getTwoFingerPinchGesture(gesture: UIPinchGestureRecognizer) {
        if gesture.scale <= 0.8 {
            platformView!.alpha = 0.8
            platformView!.hidden = false
            let awin = UIApplication.sharedApplication().windows[0]
            awin.bringSubviewToFront(platformView!)
        }
        
        if gesture.scale >= 1.2 {
            platformView!.disappear()
        }
    }
    #endif
}

//MARK: - NSURL cache
extension AppDelegate {
    func urlCacheConfig() {
        let sharedCache = NSURLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 32 * 1024 * 1024, diskPath: "NSURLCache")
        NSURLCache.setSharedURLCache(sharedCache)
    }
}


import RavenSwift
//MARK: - Raven日志系统
extension AppDelegate {
    func ravenConfig() {
        var ravenurl = ""
        #if APPSTORE
            ravenurl = G.SentryUploadURL
        #else
        #endif
        RavenClient.clientWithDSN(ravenurl)
        RavenClient.sharedClient?.setupExceptionHandler()
    }
}

//MARK: - ShareSDK相关
extension AppDelegate {
    func sharesdkConfig() {
        ShareSDK.registerApp(G.ShareSDKID,
                             activePlatforms: [SSDKPlatformType.TypeSinaWeibo.rawValue,
                                SSDKPlatformType.TypeQQ.rawValue,
                                SSDKPlatformType.TypeWechat.rawValue],
                             onImport: {(platform : SSDKPlatformType) -> Void in
                                    
                                    switch platform {
                                        
                                    case SSDKPlatformType.TypeWechat:
                                        ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                    case SSDKPlatformType.TypeQQ:
                                        ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                    case SSDKPlatformType.TypeSinaWeibo:
                                        ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                    default:
                                        break
                                    }
        }) {(platform : SSDKPlatformType,appInfo : NSMutableDictionary!) -> Void in
            switch platform {
                
            case SSDKPlatformType.TypeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo.SSDKSetupSinaWeiboByAppKey(G.WeiboAppKey,
                                                   appSecret : G.WeiboAppSecret,
                                                   redirectUri : G.WeiboRedirectUri,
                                                   authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.TypeWechat:
                //设置微信应用信息
                appInfo.SSDKSetupWeChatByAppId(G.WeChatAppID,
                                               appSecret: G.WeChatAppSecret)
            case SSDKPlatformType.TypeQQ:
                //设置QQ应用信息
                appInfo.SSDKSetupQQByAppId(G.QQAppID, appKey: G.QQAppKey, authType: SSDKAuthTypeBoth)
            default:
                break
            }
        }
    }
}



import AdSupport
//MARK: - JPUSH config
extension AppDelegate {
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        G.instance.apnsNoti = userInfo
        
        alertRemoteNoti()
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func alertRemoteNoti() {
        if let noti = G.instance.apnsNoti where G.instance.finishedStartHelp {
            if UIApplication.sharedApplication().applicationState == .Active {
                let aps = noti["aps"] as? [NSString: AnyObject?]
                let alert = aps?["alert"] as? String
                
                guard let alertStr = alert else {
                    return
                }
                
                let alertvc = UIAlertController(title: "新通知",
                                                message: alertStr,
                                                preferredStyle: .Alert)
                alertvc.addAction(UIAlertAction(title: "忽略", style: .Cancel, handler: { (action) -> Void in
                    alertvc.dismissViewControllerAnimated(true, completion: {
                        G.instance.apnsNoti = nil
                    })
                }))
                
                alertvc.addAction(UIAlertAction(title: "阅读", style: .Default, handler: { (action) -> Void in
                    self.mainDelegate.handleRemotePush()
                    alertvc.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.mainDelegate.curNavController?.topViewController?.presentViewController(alertvc, animated: true, completion: nil)
            } else {
                self.mainDelegate.handleRemotePush()
            }
        }
    }
    
    func jpushConfig(launchOptions: [NSObject: AnyObject]?) {
        
        //自定义消息
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(networkDidReceiveMessage(_:)), name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(jpushDidSetup(_:)), name: kJPFNetworkDidSetupNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(jpushDidClose(_:)), name: kJPFNetworkDidCloseNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(jpushDidRegister(_:)), name: kJPFNetworkDidRegisterNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(jpushDidLogin(_:)), name: kJPFNetworkDidLoginNotification, object: nil)
        
        
        let advertisingId = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        if !NSUserDefaults.standardUserDefaults().boolForKey(G.UserDefaultKey.closeAPNSNotification.rawValue) {
            JPUSHService.registerForRemoteNotificationTypes(UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue, categories: nil)
        }
        
        JPUSHService.setupWithOption(launchOptions,
                                     appKey: G.JPUSHAppKey,
                                     channel: G.JPUSHChannel,
                                     apsForProduction: true,
                                     advertisingIdentifier: advertisingId)
        
        JPUSHService.resetBadge()
        JPUSHService.setBadge(0)
        
        let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
        if let noti = remoteNotification {
            G.instance.apnsNoti = noti
        }
        
//        JPUSHService.setLogOFF()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func networkDidReceiveMessage(noti: NSNotification) {
        
    }
    
    func jpushDidSetup(noti: NSNotification) {
        
    }
    
    func jpushDidClose(noti: NSNotification) {
        
    }
    
    func jpushDidRegister(noti: NSNotification) {
        
    }
    
    func jpushDidLogin(noti: NSNotification) {
        setJPUSHTag()
    }
    
    func jpushError(noti: NSNotification) {
        
    }
    
    //设置jpush tag
    func setJPUSHTag() {
        var tagSet: Set<String> = []
        tagSet.insert("push_enabled")
        
        #if APPSTORE
            tagSet.insert("prod")
        #else
            tagSet.insert("dev")
        #endif
        
        
        JPUSHService.setTags(tagSet, callbackSelector: #selector(tagsAliasCallback(_:tags:alias:)), object: self)
    }
    
    func tagsAliasCallback(code: Int, tags: Set<NSObject>?, alias: String) {
//        G.logger.debug("rescode: \(code), \ntags: \(tags), \nalias: \(alias)\n")
    }
}

//MARK: - 友盟
extension AppDelegate {
    func umengConfig() {
        
    }
}

//MARK: - 启动帮助页
extension AppDelegate {
    func startHelp() {
        let enterAppHandler = {
            G.instance.finishedStartHelp = true
            
            NSNotificationCenter.defaultCenter().postNotificationName(G.NotificationName.alreadyShowHomePage.rawValue, object: nil)
            
            self.mainDelegate.handleRemotePush()
        }
        
        if !G.instance.finishedStartHelp {
            //TODO: 启动帮助页显示
            enterAppHandler()
        }
    }
}

// MARK: - Timer
extension AppDelegate {
    func registerDefaultUserDefaults() {
        let kRegisterNotificationSettings = "kRegisterNotificationSettings"
        let defaultPreferences = [kRegisterNotificationSettings : true, TimerType.Work.rawValue : 601, TimerType.Break.rawValue : 61, TimerType.Procrastination.rawValue: 121]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultPreferences)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(kRegisterNotificationSettings) {
            let restAction = UIMutableUserNotificationAction()
            restAction.identifier = "BREAK_ACTION"
            restAction.title = "Start Break"
            restAction.activationMode = .Background
            
            let workAction = UIMutableUserNotificationAction()
            workAction.identifier = "WORK_ACTION"
            workAction.title = "Start Work"
            workAction.activationMode = .Background
            
            let category = UIMutableUserNotificationCategory()
            category.setActions([workAction, restAction], forContext: .Default)
            category.identifier = "START_CATEGORY"
            
            let categories = Set([category])
            //      let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: NSSet(object: category) as Set<NSObject>)
            let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: categories)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kRegisterNotificationSettings)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
