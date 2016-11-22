//
//  UIViewController+Extension.swift
//  Daker
//
//  Created by RHCT on 16/8/22.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: - 获取当前显示的viewcontroller
extension UIViewController {
    class var currentViewController: UIViewController? {
        if let controller = UIApplication.sharedApplication().keyWindow?.rootViewController {
            return findCurrentVC(controller)
        }
        return nil
    }
    
    private class func findCurrentVC(viewController: UIViewController) -> UIViewController? {
        if let controller = viewController.presentedViewController {
            
            return findCurrentVC(controller)
        }
        else if let controller = viewController as? UISplitViewController, lastViewController = controller.viewControllers.first where controller.viewControllers.count > 0 {
            
            return findCurrentVC(lastViewController)
        }
        else if let controller = viewController as? UINavigationController, topViewController = controller.topViewController where controller.viewControllers.count > 0 {
            
            return findCurrentVC(topViewController)
        }
        else if let controller = viewController as? UITabBarController, selectedViewController = controller.selectedViewController where controller.viewControllers?.count > 0 {
            
            return findCurrentVC(selectedViewController)
        }
        else {
            
            return viewController
        }
    }
}
