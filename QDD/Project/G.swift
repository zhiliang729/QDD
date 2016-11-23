//
//  G.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: - 全局对象
class G {
    
    //MARK: - public
    
    //MARK: -- Singleton
    static let shared: G = {
        return G()
    }()
    
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
    var apnsNoti: [NSObject : AnyObject]?
    
    //MARK: -- 是否已显示过帮助页
    var finishedStartHelp: Bool = false
    
    //MARK: - private
    //MARK: -- 复写init方法
    private init() {
    }
}

