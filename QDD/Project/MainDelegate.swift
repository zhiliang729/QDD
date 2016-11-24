//
//  MainDelegate.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit

class MainDelegate: NSObject {
    
    private var naviArray: [UINavigationController] = []

    //MARK: - 当前NavigationController
    var curNavController: UINavigationController? {
        get {
            if naviArray.count > 0 {
                return naviArray.last
            } else {
                return G.appdelegate.mainTabBar.navigationController
            }
        }
        
        set (navi) {
            if navi == nil && naviArray.count > 0 {
                naviArray.removeLast()
            } else if let na = navi {
                naviArray.append(na)
            }
        }
    }
    
    //MARK: - 推出登录页
    func pushLoginViewController() {
        G.logger.debug("去登陆页")
    }
    
    //MARK: - 推出web页面
    func handleUrl(_ url: NSURL?) {
        if let handleUrl = url {
//            let web = BaseWebViewController(nibName: "BaseWebViewController", bundle: nil)
//            web.url = handleUrl
//            pushViewController(web)
        }
    }
    
    //MARK: - 处理推送
    func handleRemotePush() {
        if let _ = G.shared.apnsNoti {
            G.showMessage("推送显示了")
        }
    }
    
    //MARK: - 若未登陆，执行登录，否则执行action
    func loginOrPerformAction(_ action: @escaping () -> Void) {
        ifLogin(performAction: {
            action()
        }) {
            self.pushLoginViewController()
        }
    }
    
    //MARK: - 若未登陆，执行noLoginAction，否则执行alreadyLoginAction
    func ifLogin(performAction alreadyLoginAction: (() -> Void)?, elsePerformAction noLoginAction: (() -> Void)? ) {
        if G.userIsLogin {
            alreadyLoginAction?()
        } else {
            noLoginAction?()
        }
    }
    
    //MARK: - push viewcontroller 建议所有push都用此方法
    func push(_ vc: UIViewController) {
        
        vc.hidesBottomBarWhenPushed = true
        curNavController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITabBarControllerDelegate
extension MainDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //        G.logger.debug("hello:\(tabBarController.selectedIndex)")
    }
}

//MARK: - UINavigationControllerDelegate
extension MainDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//                G.logger.debug("hello:\(G.appdelegate.mainTabBar.selectedIndex)")
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//                G.logger.debug("hello:\(G.appdelegate.mainTabBar.selectedIndex)")
    }
}

