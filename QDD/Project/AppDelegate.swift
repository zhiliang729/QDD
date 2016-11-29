//
//  AppDelegate.swift
//  ss
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mainTabBar: UITabBarController = UITabBarController()

    var mainDelegate: MainDelegate = MainDelegate()
    
    fileprivate var hostReach: Reachability?
    
    #if APPSTORE
    #else
    fileprivate var platformView: PlatformChangeView? //平台切换view  只在 非APPSTORE下 有效
    #endif
    
    deinit {
        #if APPSTORE
        #else
            platformView!.removeObserver(self.platformView!, forKeyPath: "alpha")
        #endif
        
        
        //JPUSH
        NotificationCenter.default.removeObserver(self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //MARK: - 首先配置
        //MARK: -- 全局数据配置
        G.shared.config()
        
        //MARK: -- 平台配置
        platformConfig(platform: "")
        
        //MARK: -- 不同版本之间数据清理及升级
        appVersionConfig()
        
        //MARK: -- 启动帮助页是否已显示
        G.shared.finishedStartHelp = false
        //MARK: - 其次配置
        
        //MARK: -- Raven日志系统
        ravenConfig()
        
        //MARK: -- sharesdk
        sharesdkConfig()
        
        //MARK: -- jpush
        jpushConfig(launchOptions: launchOptions)
        
        //MARK: -- 友盟
        umengConfig()
        
        //MARK: -- 网络监测
        checkNetworkChange()
        
        //MARK: -- 设置window相关
        configWindow()
        //MARK: -- tabbar
        configTabbar()
        
        window?.makeKeyAndVisible()
        
        //MARK: -- 启动帮助页
        startHelp()
        
        //MARK: -- 手势捏合切换平台 （非APPSTORE 有效）
        #if APPSTORE
        #else
            NotificationCenter.default.addObserver(self, selector: #selector(platformChange(_:)), name: Notification.Name.App.PlatformChanged, object: nil)
            addTwoFingerPinchGesture()
        #endif
        
        return true
    }

    fileprivate func appVersionConfig() {
        let versionStr = G.appVersion
        let version = versionStr.version()
        
        let savedVersionStr = UserDefaults.standard.object(forKey: UserDefaults.Key.AppVersion) as? String
        
        if versionStr != savedVersionStr {//升级版本首次启动时，进行相应的数据处理
            UserDefaults.standard.set(false, forKey: UserDefaults.Key.CloseAPNSNotification) //默认打开推送
            
            let savedVersion = savedVersionStr?.version()
            if savedVersionStr == nil {//首次安装
                UserDefaults.standard.set(false, forKey: UserDefaults.Key.AlreadyShowStartHelp)
            } else if version.major != savedVersion?.major ?? 0 {//大版本升级
                UserDefaults.standard.set(false, forKey: UserDefaults.Key.AlreadyShowStartHelp)
            } else {//小版本升级
                if G.showStartHelp {//产品控制
                    UserDefaults.standard.set(false, forKey: UserDefaults.Key.AlreadyShowStartHelp)
                } else {
                    UserDefaults.standard.set(true, forKey: UserDefaults.Key.AlreadyShowStartHelp)
                }
            }
            
            //保存版本信息
            UserDefaults.standard.set(versionStr, forKey: UserDefaults.Key.AppVersion)
            UserDefaults.standard.synchronize()
        }
    }
    
    //MARK: -- window设置
    fileprivate func configWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
    }
    
    //MARK: -- tabbar设置
    fileprivate func configTabbar() {
        
        mainTabBar.delegate = mainDelegate
        mainTabBar.tabBar.backgroundColor = UIColor.white
        mainTabBar.tabBar.backgroundImage = UIImage(named: "tabbar_bg")//可以用从color得到图片的方法
        mainTabBar.tabBar.shadowImage = UIImage(named: "tabbar_shadow")//tabbar 顶上shadow
        
        //tabbar 顶上分割线
        let lineView = UIView(frame: CGRect(x: 0, y: -1, width: G.SCREEN_WIDTH, height: 1))
        lineView.backgroundColor = UIColor.red
        mainTabBar.tabBar.addSubview(lineView)
        
        let first = FirstViewController(nibName: "FirstViewController", bundle: nil)
        first.title = "first"
        
        let second = SecondViewController(nibName: "SecondViewController", bundle: nil)
        second.title = "second"
        
        let third = ThirdViewController(nibName: "ThirdViewController", bundle: nil)
        third.title = "third"
        
        let fourth = MineViewController(nibName: "MineViewController", bundle: nil)
        fourth.title = "fourth"
        
        mainTabBar.viewControllers = [first, second, third, fourth]
        
        let navi = UINavigationController(rootViewController: mainTabBar)
        navi.navigationBar.isHidden = true
        navi.delegate = mainDelegate
        
        window?.rootViewController = navi
        
        customTabbar()
    }
    
    func customTabbar() {
        let tabbarItemImages = ["first", "second", "third", "fourth"]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont.systemFont(ofSize: 10)], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: UIFont.systemFont(ofSize: 10)], for: .selected)
        
        var index = 0
        for item in mainTabBar.tabBar.items! {
            let selectedImgName = String(format: "%@_selected", tabbarItemImages[index])
            let selectedImg = UIImage(named: selectedImgName)?.withRenderingMode(.alwaysOriginal)
            
            let unSelectedImgName = String(format: "%@_normal", tabbarItemImages[index])
            let unSelectedImg = UIImage(named: unSelectedImgName)?.withRenderingMode(.alwaysOriginal)
            
            item.selectedImage = selectedImg
            item.image = unSelectedImg
            
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
            index += 1
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 9
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        JPUSHService.resetBadge()
        JPUSHService.setBadge(0)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

//MARK: - 检测网络变化
extension AppDelegate {
    func checkNetworkChange() {
        if (hostReach != nil) {
            hostReach?.stopNotifier()
            hostReach = nil
        }
        
        var hostUrlName: String?
        if G.platformBaseUrl.contains("https") {
            let index = "https://".index("https://".startIndex, offsetBy: "https://".characters.count)
            hostUrlName = G.platformBaseUrl.substring(from: index)
        } else {
            let index = "http://".index("http://".startIndex, offsetBy: "http://".characters.count)
            hostUrlName = G.platformBaseUrl.substring(from: index)
        }
        
        do {
            hostReach = Reachability(hostname: hostUrlName!)
            try hostReach?.startNotifier()
        } catch {
            G.logger.debug("\n*********** 网络监测未初始化成功 \n**********\n")
        }
    }
}

//MARK: - 平台配置
extension AppDelegate {
    
    func platformConfig(platform: String) {
        var plat = platform
        let savedPlatform = UserDefaults.standard.object(forKey: UserDefaults.Key.AppPlatform) as? String
        
        if plat.characters.count == 0 {
            #if APPSTORE
                let value = UserDefaults.Key.AppProdPlatform
            #else
                let value = UserDefaults.Key.AppDevPlatform
            #endif
            
            plat = savedPlatform ?? value
        }
        
        if savedPlatform == nil {//首次打开app
            //do nothing
        } else if plat == savedPlatform {//同一平台
            //do nothing
        } else {//不同平台，执行切换相关操作
            
            //执行退出登录的操作，清除用户信息
            G.shared.user = nil
            User.cancelAuthorize()
        }
        
        UserDefaults.standard.set(plat, forKey: UserDefaults.Key.AppPlatform)
        UserDefaults.standard.synchronize()
    }
    
    
    #if APPSTORE
    #else
    func platformChange(_ noti: NSNotification) {
        checkNetworkChange()
    }
    
    func addTwoFingerPinchGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(getTwoFingerPinchGesture(_:)))
        window?.addGestureRecognizer(gesture)
        
        platformView = PlatformChangeView(frame: UIScreen.main.bounds)
        platformView!.addObserver(platformView!, forKeyPath: "alpha", options: .new, context: nil)
        let awin = UIApplication.shared.windows[0]
        platformView!.isHidden = true
        awin.addSubview(platformView!)
    }
    
    func getTwoFingerPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if gesture.scale <= 0.8 {
            platformView!.alpha = 0.8
            platformView!.isHidden = false
            let awin = UIApplication.shared.windows[0]
            awin.bringSubview(toFront: platformView!)
        }
        
        if gesture.scale >= 1.2 {
            platformView!.disappear()
        }
    }
    #endif
}


import SentrySwift
//MARK: - Raven日志系统
extension AppDelegate {
    func ravenConfig() {
        var ravenurl = ""
        #if APPSTORE
            ravenurl = G.SentryUploadURL
        #else
        #endif
        SentryClient.shared = SentryClient(dsnString: ravenurl)
        SentryClient.shared?.startCrashHandler()
        SentryClient.shared?.user = SentrySwift.User(id: "1", email: "zhiliang729@163.com", username: "zhangliang", extra: ["is_admin": false])
    }
}

//MARK: - ShareSDK相关
extension AppDelegate {
    func sharesdkConfig() {
        
        /**
         *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
         *  在将生成的AppKey传入到此方法中。
         *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
         *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
         *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
         */
        
        ShareSDK.registerApp(G.ShareSDKID, activePlatforms:[
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeWechat.rawValue,
            SSDKPlatformType.typeQQ.rawValue],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform
                                {
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                default:
                                    break
                                }
                                
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
            switch platform
            {
            case SSDKPlatformType.typeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo?.ssdkSetupSinaWeibo(byAppKey: G.WeiboAppKey,
                                            appSecret : G.WeiboAppSecret,
                                            redirectUri : G.WeiboRedirectUri,
                                            authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeWechat:
                //设置微信应用信息
                appInfo?.ssdkSetupWeChat(byAppId: G.WeChatAppID, appSecret: G.WeChatAppSecret)
            case SSDKPlatformType.typeQQ:
                //设置QQ应用信息
                appInfo?.ssdkSetupQQ(byAppId: G.QQAppID,
                                     appKey : G.QQAppKey,
                                     authType : SSDKAuthTypeBoth)
            default:
                break
            }
        }
    }
}



import AdSupport
import UserNotifications
//MARK: - JPUSH config
extension AppDelegate: JPUSHRegisterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        G.shared.apnsNoti = userInfo
        
        alertRemoteNoti()
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func alertRemoteNoti() {
        
        if let noti = G.shared.apnsNoti, G.shared.finishedStartHelp {
            if UIApplication.shared.applicationState == .active {
                let aps = noti["aps" as NSString] as? [String: AnyObject?]
                let alert = aps?["alert"] as? String
                
                guard let alertStr = alert else {
                    return
                }
                
                let alertvc = UIAlertController(title: "新通知",
                                                message: alertStr,
                                                preferredStyle: .alert)
                alertvc.addAction(UIAlertAction(title: "忽略", style: .cancel, handler: { (action) -> Void in
                    alertvc.dismiss(animated: true, completion: {
                        G.shared.apnsNoti = nil
                    })
                }))
                
                alertvc.addAction(UIAlertAction(title: "阅读", style: .default, handler: { (action) -> Void in
                    self.mainDelegate.handleRemotePush()
                    alertvc.dismiss(animated: true, completion: nil)
                }))
                self.mainDelegate.curNavController?.topViewController?.present(alertvc, animated: true, completion: nil)
            } else {
                self.mainDelegate.handleRemotePush()
            }
        }
    }
    
    func jpushConfig(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        //自定义消息
        NotificationCenter.default.addObserver(self, selector: #selector(networkDidReceiveMessage(_:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(jpushDidSetup(_:)), name: NSNotification.Name.jpfNetworkDidSetup, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(jpushDidClose(_:)), name: NSNotification.Name.jpfNetworkDidClose, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(jpushDidRegister(_:)), name: NSNotification.Name.jpfNetworkDidRegister, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(jpushDidLogin(_:)), name: NSNotification.Name.jpfNetworkDidLogin, object: nil)
        
        
        let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if !UserDefaults.standard.bool(forKey: UserDefaults.Key.CloseAPNSNotification) {
            
            if #available(iOS 10, *) {
                let entity = JPUSHRegisterEntity()
                entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue) |
                    NSInteger(UNAuthorizationOptions.sound.rawValue) |
                    NSInteger(UNAuthorizationOptions.badge.rawValue)
                JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
            } else {
                JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue, categories: nil)
            }
        }
        
        JPUSHService.setup(withOption: launchOptions,
                                     appKey: G.JPUSHAppKey,
                                     channel: G.JPUSHChannel,
                                     apsForProduction: true,
                                     advertisingIdentifier: advertisingId)
        
        JPUSHService.resetBadge()
        JPUSHService.setBadge(0)
        
        let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
        if let noti = remoteNotification as? [AnyHashable : Any] {
            G.shared.apnsNoti = noti as [AnyHashable : Any]
        }
        
        JPUSHService.setLogOFF()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {

        if notification.request.trigger is UNPushNotificationTrigger {
            let userInfo = notification.request.content.userInfo
            G.shared.apnsNoti = userInfo
            
            alertRemoteNoti()
            
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(0)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        if response.notification.request.trigger is UNPushNotificationTrigger {
            let userInfo = response.notification.request.content.userInfo
            G.shared.apnsNoti = userInfo
            
            alertRemoteNoti()
            
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    
    func networkDidReceiveMessage(_ noti: NSNotification) {
        
    }
    
    func jpushDidSetup(_ noti: NSNotification) {
        
    }
    
    func jpushDidClose(_ noti: NSNotification) {
        
    }
    
    func jpushDidRegister(_ noti: NSNotification) {
        
    }
    
    func jpushDidLogin(_ noti: NSNotification) {
        setJPUSHTag()
    }
    
    func jpushError(_ noti: NSNotification) {
        
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
    
    func tagsAliasCallback(_ code: Int, tags: Set<NSObject>?, alias: String) {
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
            G.shared.finishedStartHelp = true
            
            NotificationCenter.default.post(name: Notification.Name.App.AlreadyShowHomePage, object: nil)
            
            self.mainDelegate.handleRemotePush()
        }
        
        if !G.shared.finishedStartHelp {
            //TODO: 启动帮助页显示
            enterAppHandler()
        }
    }
}
