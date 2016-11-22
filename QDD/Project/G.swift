//
//  G.swift
//  Daker
//
//  Created by RHCT on 16/7/28.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import XCGLogger

class G {
    
    
    
    //MARK: - PUBLIC
    
    //MARK: -- 单例
    static let instance = G()
    
    //MARK: -- 当前登录用户
    var user: User? {
        didSet {
            if user == nil {
                User.clearCurrentUserInfo()
            } else {
                User.synchronizeCurrentUserInfo()
            }
        }
    }
    
    //MARK: -- apns noti
    var apnsNoti: AnyObject?
    
    //MARK: -- 是否已显示过帮助页
    var finishedStartHelp: Bool = false
    
    //MARK: - private
    //MARK: -- 复写init方法
    private init() {
    }
}

